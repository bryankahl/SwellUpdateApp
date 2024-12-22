//
//  WeatherAPIResponse.swift
//  SwellUpdate
//
//  Created by Bryan Kahl on 11/27/24.
//
//

import Foundation

//struct represents the response model for the Open-Meteo API
//It decodes the JSON data received from the API
struct OpenMeteoResponse: Decodable {
    //Nested struct for Hourly forecast data
    struct Hourly: Decodable {
        let time: [String]?     //Array of times for hourly data
        let wave_height: [Double]?  //Array of wave heights, direction, period at correspondiong times
        let wave_direction: [Double]?
        let wave_period: [Double]?
    }
    let hourly: Hourly?   //The hourly forecast data
}

// Simplified SurfForecast struct repressents the surf forecast for specific spot
struct SurfForecast: Codable, Hashable {
    let spotName: String
    let waveHeight: Double
    let waveDirection: Double
    let wavePeriod: Double
    let surfRating: String
}

// Function to calculate the surf rating
class SurfRatingCalculator {
    //method calculates rating based on wave height retrieved from API
    static func calculateRating(waveHeight: Double) -> String {
        if waveHeight > 4.0 {
            return "Excellent"
        } else if waveHeight > 2.0 {
            return "Good"
        } else {
            return "Poor"
        }
    }
}
