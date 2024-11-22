//
//  ForecastTableViewController.swift
//  SwellUpdate
//
//  Created by Bryan Kahl on 11/23/24.
//

import Foundation
import UIKit

extension ForecastTableViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        // Get the search text
        guard let searchText = searchController.searchBar.text, !searchText.isEmpty else {
            filteredForecasts = []
            tableView.reloadData()
            return
        }

        // Filter the forecasts
        filteredForecasts = forecasts.filter { forecast in
            return forecast.spotName.lowercased().contains(searchText.lowercased())
        }

        // Reload the table view
        tableView.reloadData()
    }
}


class ForecastTableViewController: UITableViewController {

    // Data source for the table view
    var forecasts: [SurfForecast] = []
    var searchController: UISearchController!
    var filteredForecasts: [SurfForecast] = []

    var isSearching: Bool {
        return searchController.isActive && !searchController.searchBar.text!.isEmpty
    }



    override func viewDidLoad() {
        super.viewDidLoad()
        // Set the row height (choose one of the two options below)
        // Option 1: Dynamic height using Auto Layout
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 100
        // Set up the search controller
            searchController = UISearchController(searchResultsController: nil)
            searchController.searchResultsUpdater = self
            searchController.obscuresBackgroundDuringPresentation = false
            searchController.searchBar.placeholder = "Search for surf spots"
            navigationItem.searchController = searchController

            // Ensure the search bar is always visible
            navigationItem.hidesSearchBarWhenScrolling = false
        // Fetch data to populate the table
        fetchSurfData()
    }

    // Fetch simulated surf data
    func fetchSurfData() {
        // Simulated list of beaches with coordinates
        let beachData = [
            ("Santa Monica Beach", 34.0195, -118.4912),
            ("Venice Beach", 33.9850, -118.4695),
            ("Huntington Beach", 33.6595, -117.9988),
            ("Laguna Beach", 33.5427, -117.7854),
            ("Malibu Beach", 34.0259, -118.7798)
        ]

        // Map simulated data to create SurfForecast instances
        forecasts = beachData.map { beach in
            SurfForecast(
                spotName: beach.0, // Use the unique beach name
                waveHeight: Double.random(in: 2.0...6.0), // Random wave height
                windSpeed: Double.random(in: 5.0...20.0), // Random wind speed
                surfRating: SurfRatingCalculator.calculateRating(waveHeight: Double.random(in: 2.0...6.0))
            )
        }

        // Reload the table view on the main thread
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }

    // TableView Data Source: Number of rows
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return isSearching ? filteredForecasts.count : forecasts.count
    }

    // TableView Data Source: Configure each cell
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ForecastCell", for: indexPath) as! ForecastTableViewCell
            let forecast = isSearching ? filteredForecasts[indexPath.row] : forecasts[indexPath.row]

            // Populate the custom labels
            cell.beachNameLabel.text = "\(forecast.spotName) - \(forecast.surfRating)"
            cell.waveHeightLabel.text = "Wave Height: \(forecast.waveHeight) ft"

            return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail",
           let destination = segue.destination as? ForecastDetailViewController,
           let indexPath = tableView.indexPathForSelectedRow {
            // Pass the selected forecast data
            destination.selectedForecast = forecasts[indexPath.row]
        }
    }

}
