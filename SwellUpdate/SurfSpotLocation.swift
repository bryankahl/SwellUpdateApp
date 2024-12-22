//
//  SurfSpotLocation.swift
//  SwellUpdate
//
//  Created by Bryan Kahl on 11/27/24.
//

import Foundation

// the data model for a surf spot location.
struct SurfSpotLocation: Decodable {
    let name: String         // The name of the surf spot (e.g., "Pipeline").
    let country: String      // The country where the surf spot is located.
    let latitude: Double?    // Latitude coordinate of the surf spot.
    let longitude: Double?   // Longitude coordinate of the surf spot.

    // Coding keys used for decoding JSON data.
    // Maps JSON keys (e.g., "lat", "lng") to Swift property names.
    enum CodingKeys: String, CodingKey {
        case name
        case country
        case latitude = "lat"
        case longitude = "lng"
    }

    // Custom initializer to decode latitude and longitude, supporting both String and Double types.
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Decode required properties.
        name = try container.decode(String.self, forKey: .name)
        country = try container.decode(String.self, forKey: .country)

        // Decode latitude, handling cases where it might be a String or Double.
        if let latString = try? container.decode(String.self, forKey: .latitude) {
            latitude = Double(latString) // Convert String to Double if needed.
        } else {
            latitude = try? container.decode(Double.self, forKey: .latitude) // Directly decode as Double.
        }

        // Decode longitude, handling cases where it might be a String or Double.
        if let lngString = try? container.decode(String.self, forKey: .longitude) {
            longitude = Double(lngString) // Convert String to Double if needed.
        } else {
            longitude = try? container.decode(Double.self, forKey: .longitude) // Directly decode as Double.
        }
    }

    // Sanitized version of the name, suitable for Firebase keys.
    var sanitizedName: String {
        return sanitizeFirebaseKey(name)
    }
}
