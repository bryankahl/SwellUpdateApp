//
//  SurfSpotDataLoader.swift
//  SwellUpdate
//
//  Created by Bryan Kahl on 11/27/24
//

import Foundation

// A utility class to load surf spot data from a local JSON file.
class SurfSpotDataLoader {
    // Static function to load surf spots from a JSON file bundled in the app.
    // - Returns: An array of `SurfSpotLocation` objects or `nil` if loading fails.
    static func loadSurfSpots() -> [SurfSpotLocation]? {
        // Locate the `testSpots.json` file in the app's main bundle.
        guard let url = Bundle.main.url(forResource: "surfspots", withExtension: "json"),
              let data = try? Data(contentsOf: url) else {
            // If the file cannot be found or loaded, log an error and return `nil`.
            print("Failed to load surf spot JSON.")
            return nil
        }

        do {
            // Decode the JSON data into an array of `SurfSpotLocation` objects.
            let decoder = JSONDecoder()
            let spots = try decoder.decode([SurfSpotLocation].self, from: data)
            
            // Print the count of loaded spots for debugging purposes.
            print("Loaded \(spots.count) surf spots.")
            return spots
        } catch {
            // Handle any errors during decoding and log the error.
            print("Error decoding surf spot JSON: \(error.localizedDescription)")
            return nil
        }
    }
}
