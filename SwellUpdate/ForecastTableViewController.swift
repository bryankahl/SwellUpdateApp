//
//  ForecastTableViewController.swift
//  SwellUpdate
//
//  Created by Bryan Kahl on 11/24/24.
//

import Foundation
import UIKit

// Extension to handle search functionality for the forecast table view.
extension ForecastTableViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        // Filter the forecasts based on the user's search text.
        guard let searchText = searchController.searchBar.text, !searchText.isEmpty else {
            filteredForecasts = [] // Clear the filtered results if the search text is empty.
            tableView.reloadData()
            return
        }

        // Update filteredForecasts by checking if the spot name contains the search text.
        filteredForecasts = forecasts.filter { forecast in
            forecast.spotName.lowercased().contains(searchText.lowercased())
        }
        tableView.reloadData() // Refresh the table view to display search results.
    }
}

// Displays a list of surf forecasts in a table view.
class ForecastTableViewController: UITableViewController {

    // MARK: - Properties
    var forecasts: [SurfForecast] = [] // Array of all surf forecasts.
    var searchController: UISearchController! // Search controller for filtering forecasts.
    var filteredForecasts: [SurfForecast] = [] // Array of forecasts filtered by search.
    var surfSpotLocations: [SurfSpotLocation] = [] // Array of surf spot data.

    // Computed property to check if the search bar is active and has input.
    var isSearching: Bool {
        return searchController.isActive && !searchController.searchBar.text!.isEmpty
    }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the table view's delegate and data source.
        tableView.delegate = self
        tableView.dataSource = self

        // Register the custom cell for reuse.
        tableView.register(UINib(nibName: "ForecastTableViewCell", bundle: nil), forCellReuseIdentifier: "ForecastCell")

        // Configure row height for dynamic resizing.
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 100

        // Set up the search controller.
        searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search for surf spots"

        // Style the search bar for better UI.
        searchController.searchBar.barTintColor = UIColor.systemTeal
        searchController.searchBar.backgroundImage = UIImage() // Remove default background.
        searchController.searchBar.searchTextField.backgroundColor = UIColor.systemTeal.withAlphaComponent(0.2)
        searchController.searchBar.searchTextField.layer.cornerRadius = 10
        searchController.searchBar.searchTextField.clipsToBounds = true

        // Add the search bar to the navigation item.
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false

        // Load the surf spots and their forecasts.
        loadSurfSpots()
    }

    // MARK: - Load Data
    func loadSurfSpots() {
        // Load surf spots from a JSON file and fetch their forecasts.
        if let spots = SurfSpotDataLoader.loadSurfSpots() {
            surfSpotLocations = spots
            print("Loaded \(surfSpotLocations.count) surf spots.")
            fetchForecasts()
        } else {
            print("Failed to load surf spots.")
        }
    }

    func fetchForecasts() {
        // Fetch forecasts for all surf spots.
        for spot in surfSpotLocations {
            SurfSpotService.shared.fetchForecast(for: spot) { forecast in
                guard let forecast = forecast else { return }
                DispatchQueue.main.async {
                    self.forecasts.append(forecast)
                    self.tableView.reloadData() // Reload the table view when a new forecast is added.
                }
            }
        }
    }

    // MARK: - Table View Data Source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Return the count of forecasts or filtered forecasts depending on the search state.
        return isSearching ? filteredForecasts.count : forecasts.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Dequeue a reusable cell for the forecast.
        let cell = tableView.dequeueReusableCell(withIdentifier: "ForecastCell", for: indexPath) as! ForecastTableViewCell
        let forecast = isSearching ? filteredForecasts[indexPath.row] : forecasts[indexPath.row]

        // Configure the cell with the forecast data.
        cell.beachNameLabel.text = forecast.spotName
        cell.ratingLabel.text = forecast.surfRating

        // Add styling to the cell for a better visual appearance.
        cell.layer.shadowColor = UIColor.black.cgColor
        cell.layer.shadowOpacity = 0.1
        cell.layer.shadowOffset = CGSize(width: 0, height: 2)
        cell.layer.shadowRadius = 4
        cell.layer.masksToBounds = false
        cell.contentView.backgroundColor = .clear
        cell.backgroundColor = .clear

        return cell
    }

    // MARK: - Table View Delegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Get the selected forecast (filtered or unfiltered).
        let selectedForecast = isSearching ? filteredForecasts[indexPath.row] : forecasts[indexPath.row]

        // Navigate to the detail view for the selected forecast.
        if let detailVC = storyboard?.instantiateViewController(withIdentifier: "ForecastDetailViewController") as? ForecastDetailViewController {
            detailVC.selectedForecast = selectedForecast

            UIView.animate(withDuration: 0.3) {
                if let cell = tableView.cellForRow(at: indexPath) as? ForecastTableViewCell {
                    // Add a highlight effect to the selected cell.
                    cell.contentView.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.5)
                }
            } completion: { _ in
                tableView.deselectRow(at: indexPath, animated: true)
                self.navigationController?.pushViewController(detailVC, animated: true)
            }
        }
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70 // Set a fixed height for each row.
    }

    // MARK: - Table View Header
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        // Create a custom header view for the table.
        let headerView = UIView()
        headerView.backgroundColor = UIColor.systemTeal

        let titleLabel = UILabel()
        titleLabel.text = "Surf Spot Forecasts"
        titleLabel.textColor = .white
        titleLabel.font = UIFont.boldSystemFont(ofSize: 18)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        headerView.addSubview(titleLabel)
        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: headerView.centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: headerView.centerYAnchor)
        ])

        return headerView
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50 // Set a fixed height for the header.
    }

    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail",
           let destination = segue.destination as? ForecastDetailViewController,
           let indexPath = tableView.indexPathForSelectedRow {
            // Pass the selected forecast to the detail view controller.
            let selectedForecast = isSearching ? filteredForecasts[indexPath.row] : forecasts[indexPath.row]
            destination.selectedForecast = selectedForecast
        }
    }
}
