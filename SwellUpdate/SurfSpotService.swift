//
//  SurfSpotService.swift
//  SwellUpdate
//
//  Created by Bryan Kahl on 11/27/24.
//

import Foundation

// A service class for managing API requests to fetch surf forecast data.
class SurfSpotService {
    // Singleton instance of the service for global access.
    static let shared = SurfSpotService()
    
    // Function to fetch the surf forecast for a given surf spot.
    // - Parameters:
    //   - spot: The SurfSpotLocation containing latitude, longitude, and name of the surf spot.
    //   - completion: A closure that returns a SurfForecast object or nil if an error occurs.
    func fetchForecast(for spot: SurfSpotLocation, completion: @escaping (SurfForecast?) -> Void) {
        // Validate latitude and longitude values for the surf spot.
        guard let lat = spot.latitude, let lon = spot.longitude else {
            print("Invalid coordinates for \(spot.name)")
            completion(nil)
            return
        }

        // Construct the API URL for the Open-Meteo marine endpoint.
        let urlString = "https://marine-api.open-meteo.com/v1/marine?latitude=\(lat)&longitude=\(lon)&hourly=wave_height,wave_direction,wave_period&timezone=auto"
        
        // Ensure the URL string is valid.
        guard let url = URL(string: urlString) else {
            print("Invalid URL for Open-Meteo API")
            completion(nil)
            return
        }

        // Create a data task to fetch the data from the API.
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                // Handle any errors encountered during the request.
                print("Error fetching forecast data: \(error.localizedDescription)")
                completion(nil)
                return
            }

            guard let data = data else {
                // Ensure data was received from the API.
                print("No data received from API")
                completion(nil)
                return
            }

            // Debugging: Print the raw JSON response from the API.
            if let rawJSON = String(data: data, encoding: .utf8) {
                print("API Response for \(spot.name): \(rawJSON)")
            }

            do {
                // Decode the API response into the OpenMeteoResponse model.
                let apiResponse = try JSONDecoder().decode(OpenMeteoResponse.self, from: data)
                
                // Extract hourly data from the response.
                guard let hourly = apiResponse.hourly,
                      let times = hourly.time,
                      let waveHeights = hourly.wave_height,
                      let waveDirections = hourly.wave_direction,
                      let wavePeriods = hourly.wave_period else {
                    print("Missing or incomplete hourly data for \(spot.name)")
                    completion(nil)
                    return
                }

                // Find the index of the time closest to the current time.
                let currentTime = ISO8601DateFormatter().string(from: Date())
                if let currentIndex = times.firstIndex(where: { $0 >= currentTime }) {
                    // Extract data for the current time.
                    let waveHeight = waveHeights[currentIndex]
                    let waveDirection = waveDirections[currentIndex]
                    let wavePeriod = wavePeriods[currentIndex]

                    // Create a SurfForecast object with the extracted data.
                    let forecast = SurfForecast(
                        spotName: spot.name,
                        waveHeight: waveHeight,
                        waveDirection: waveDirection,
                        wavePeriod: wavePeriod,
                        surfRating: SurfRatingCalculator.calculateRating(waveHeight: waveHeight)
                    )

                    // Pass the forecast back to the caller via the completion handler.
                    completion(forecast)
                } else {
                    print("No matching forecast data for current time.")
                    completion(nil)
                }
            } catch {
                // Handle errors during JSON decoding.
                print("Error decoding forecast data: \(error.localizedDescription)")
                completion(nil)
            }
        }
        
        // Start the data task.
        task.resume()
    }
}

// Utility function to sanitize Firebase keys by replacing invalid characters.
// Firebase keys cant have . $ # or []
// - Parameter key: The original key to sanitize.
// - Returns: A sanitized key with invalid characters replaced by "_".
func sanitizeFirebaseKey(_ key: String) -> String {
    return key.replacingOccurrences(of: ".", with: "_")
              .replacingOccurrences(of: "#", with: "_")
              .replacingOccurrences(of: "$", with: "_")
              .replacingOccurrences(of: "[", with: "_")
              .replacingOccurrences(of: "]", with: "_")
}
