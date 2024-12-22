//
//  MapViewController.swift
//  SwellUpdate
//
//  Created by Bryan Kahl on 11/24/24.
//

import Foundation
import UIKit
import MapKit
import CoreLocation

class MapViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate, UISearchBarDelegate {
    
    // Outlet

    @IBOutlet weak var mapView: MKMapView!
    // Location Manager
    let locationManager = CLLocationManager()

    // Surf Spot Data
    var surfSpotLocations: [SurfSpotLocation] = []
    var forecasts: [SurfForecast] = []
    var hasZoomedToUserLocation = false

    @IBAction func centerMapOnUserLocation(_ sender: UIButton) {
        if let userLocation = locationManager.location?.coordinate {
                let region = MKCoordinateRegion(
                    center: userLocation,
                    span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                )
                mapView.setRegion(region, animated: true)
            } else {
                print("User location is not available.")
            }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Set delegates
        mapView.delegate = self
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.requestWhenInUseAuthorization()
        // Load surf spots
        loadSurfSpots()
        // Request Location Permissions
        checkLocationAuthorization()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // Get the height of the tab bar
        let tabBarHeight = tabBarController?.tabBar.frame.height ?? 0
        
        // Set the mapView frame to fill the view, excluding the tab bar area
        mapView.frame = CGRect(
            x: 0,
            y: 0,
            width: self.view.bounds.width,
            height: self.view.bounds.height - tabBarHeight
        )
    }
    
    // MARK: - Location Services
    func checkLocationAuthorization() {
        print("Authorization Status: \(locationManager.authorizationStatus)")
        switch locationManager.authorizationStatus {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .authorizedAlways, .authorizedWhenInUse:
            locationManager.startUpdatingLocation()
            mapView.showsUserLocation = true
        case .restricted, .denied:
            showLocationServicesAlert()
        @unknown default:
            break
        }
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        checkLocationAuthorization()
    }


    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let userLocation = locations.first, !hasZoomedToUserLocation {
            hasZoomedToUserLocation = true // Ensure this only happens once

            let region = MKCoordinateRegion(
                center: userLocation.coordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
            )
            mapView.setRegion(region, animated: true)
        }
    }

    // MARK: - Load Surf Spots
    func loadSurfSpots() {
        if let spots = SurfSpotDataLoader.loadSurfSpots() {
            surfSpotLocations = spots
            print("Loaded \(surfSpotLocations.count) surf spots.")
            for spot in surfSpotLocations {
                print("Spot: \(spot.name), Lat: \(spot.latitude ?? 0.0), Lng: \(spot.longitude ?? 0.0)")
            }
            addSurfSpotAnnotations()
        } else {
            print("Failed to load surf spots.")
        }
    }


    // MARK: - Add Annotations
    func addSurfSpotAnnotations() {
        print("Adding annotations...")
        for spot in surfSpotLocations {
            guard let lat = spot.latitude, let lng = spot.longitude else {
                print("Skipping \(spot.name): Invalid coordinates.")
                continue
            }

            let annotation = MKPointAnnotation()
            annotation.title = spot.name
            annotation.coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lng)
            mapView.addAnnotation(annotation)
            print("Added annotation for \(spot.name) at (\(lat), \(lng)).")
        }
    }

    
    func showLocationServicesAlert() {
        DispatchQueue.main.async {
            let alert = UIAlertController(
                title: "Location Services Disabled",
                message: "Please enable location services in your device settings to view surf spots near you.",
                preferredStyle: .alert
            )

            alert.addAction(UIAlertAction(title: "Open Settings", style: .default) { _ in
                if let appSettings = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(appSettings)
                }
            })

            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            self.present(alert, animated: true)
        }
    }

    // MARK: - Annotation View
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard !(annotation is MKUserLocation) else { return nil } // Skip the user's location annotation

        let identifier = "SurfSpotAnnotation"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKMarkerAnnotationView

        if annotationView == nil {
            // Create a new annotation view if none can be reused
            annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            annotationView?.canShowCallout = true
        } else {
            // Update the reused annotation view with the current annotation
            annotationView?.annotation = annotation
        }

        // Apply the desired styling
        annotationView?.glyphImage = UIImage(systemName: "tropicalstorm") // SF Symbol
        annotationView?.markerTintColor = UIColor.systemTeal // Teal color
        annotationView?.glyphTintColor = UIColor.white // White glyph color

        // Add a callout accessory button
        let optionsButton = UIButton(type: .detailDisclosure)
        annotationView?.rightCalloutAccessoryView = optionsButton

        return annotationView
    }



    // MARK: - Handle Callout Taps
    func mapView(_ mapView: MKMapView, annotationView: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        guard let annotation = annotationView.annotation else { return }

        let alert = UIAlertController(title: annotation.title ?? "Options", message: "What would you like to do?", preferredStyle: .actionSheet)

        // Option 1: Open Detail View
        alert.addAction(UIAlertAction(title: "View Details", style: .default, handler: { _ in
            self.openDetailView(for: annotation)
        }))

        // Option 2: Navigate to Spot
        alert.addAction(UIAlertAction(title: "Navigate Here", style: .default, handler: { _ in
            self.navigateToSpot(annotation)
        }))

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true, completion: nil)
    }

    // MARK: - Open Detail View
    func openDetailView(for annotation: MKAnnotation) {
        guard let spotName = annotation.title ?? nil else {
            print("Annotation title is nil or invalid.")
            return
        }

        if let detailVC = storyboard?.instantiateViewController(withIdentifier: "ForecastDetailViewController") as? ForecastDetailViewController {
            // Find the selected spot from the annotation
            if let selectedSpot = surfSpotLocations.first(where: { $0.name == spotName }) {
                detailVC.selectedSpot = selectedSpot

                // Always fetch the latest forecast data
                SurfSpotService.shared.fetchForecast(for: selectedSpot) { forecast in
                    DispatchQueue.main.async {
                        if let forecast = forecast {
                            detailVC.selectedForecast = forecast
                            detailVC.updateUI() // Ensure the DetailView updates
                            detailVC.fetchMediaMetadata() // Ensure media is fetched after forecast
                        }
                    }
                }
            }

            navigationController?.pushViewController(detailVC, animated: true)
        }
    }
    
    // MARK: - Navigate to Spot
    func navigateToSpot(_ annotation: MKAnnotation) {
        let mapItem = MKMapItem(placemark: MKPlacemark(coordinate: annotation.coordinate))
        mapItem.name = annotation.title ?? "Surf Spot"
        mapItem.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving])
    }
}


