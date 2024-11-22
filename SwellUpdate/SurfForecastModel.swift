//
//  SurfForecastModel.swift
//  SwellUpdate
//
//  Created by Bryan Kahl on 11/23/24.
//

import Foundation

// MARK: - API Response Model
struct SurfForecastResponse: Decodable {
    let hours: [HourData]

    func toSurfForecasts() -> [SurfForecast] {
        return hours.map { hour in
            SurfForecast(
                spotName: "Santa Monica Beach", // Placeholder for now
                waveHeight: hour.waveHeight.noaa ?? 0.0,
                windSpeed: hour.windSpeed.noaa ?? 0.0,
                surfRating: SurfRatingCalculator.calculateRating(waveHeight: hour.waveHeight.noaa ?? 0.0)
            )
        }
    }
}

struct HourData: Decodable {
    let waveHeight: WeatherData
    let windSpeed: WeatherData
}

struct WeatherData: Decodable {
    let noaa: Double?
}

// MARK: - Local Surf Forecast Model
struct SurfForecast {
    let spotName: String
    let waveHeight: Double
    let windSpeed: Double
    let surfRating: String
}

// MARK: - Surf Rating Logic
class SurfRatingCalculator {
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
