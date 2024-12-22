//
//  FavoritesTableViewController.swift
//  SwellUpdate
//
//  Created by Bryan Kahl on 11/24/24.
//

import Foundation
import UIKit
import FirebaseAuth

class FavoritesTableViewController: UITableViewController {
    
    var favoriteSpots: [SurfForecast] = []

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Load favorite spots from FavoritesManager
        favoriteSpots = FavoritesManager.shared.getFavorites()
        tableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Explicitly register the prototype cell
        tableView.register(FavoritesTableViewCell.self, forCellReuseIdentifier: "FavoriteCell")

        tableView.rowHeight = 100 // Adjust as needed
        tableView.separatorStyle = .none
        tableView.backgroundColor = UIColor.systemGroupedBackground
    }


    
    @IBAction func logoutButtonTapped(_ sender: UIBarButtonItem) {
        do {
                try Auth.auth().signOut()
                
                // Navigate back to the login screen
                if let loginVC = storyboard?.instantiateViewController(withIdentifier: "LoginViewController") {
                    if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate {
                        sceneDelegate.window?.rootViewController = loginVC
                        sceneDelegate.window?.makeKeyAndVisible()
                    }
                }
            } catch let signOutError as NSError {
                print("Error signing out: %@", signOutError)
                let alert = UIAlertController(title: "Error", message: "Unable to sign out. Please try again.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                present(alert, animated: true)
            }
    }
    

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return favoriteSpots.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "FavoriteCell", for: indexPath) as? FavoritesTableViewCell else {
            fatalError("Failed to dequeue FavoritesTableViewCell")
        }

        let forecast = favoriteSpots[indexPath.row]
        cell.textLabel?.text = forecast.spotName
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Get the selected forecast
        let selectedForecast = favoriteSpots[indexPath.row]

        // Instantiate the ForecastDetailViewController
        if let detailVC = storyboard?.instantiateViewController(withIdentifier: "ForecastDetailViewController") as? ForecastDetailViewController {
            // Pass the selected forecast to the detail view controller
            detailVC.selectedForecast = selectedForecast

            // Navigate to the detail view controller
            navigationController?.pushViewController(detailVC, animated: true)
        }

        // Deselect the row
        tableView.deselectRow(at: indexPath, animated: true)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetailFromFavorites",
           let detailVC = segue.destination as? ForecastDetailViewController,
           let indexPath = tableView.indexPathForSelectedRow {
            // Fetch the selected spot
            let selectedFavorite = favoriteSpots[indexPath.row]
            
            // Pass the forecast to the detail view
            detailVC.selectedForecast = selectedFavorite
            
            // Find and pass the related SurfSpotLocation
            if let spotLocation = SurfSpotDataLoader.loadSurfSpots()?.first(where: { $0.name == selectedFavorite.spotName }) {
                detailVC.selectedSpot = spotLocation
            }
        }
    }

    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        // Adjust content inset for safe area
        tableView.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 0, right: 0)
        tableView.scrollIndicatorInsets = tableView.contentInset
    }

}
