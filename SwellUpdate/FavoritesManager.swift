//
//  FavoritesManager.swift
//  SwellUpdate
//
//  Created by Bryan Kahl on 11/24/24.
//
import Foundation

class FavoritesManager {
    static let shared = FavoritesManager()

    private let favoritesKey = "FavoriteSurfSpots"

    //gets list of favorite surf spots
    func getFavorites() -> [SurfForecast] {
        if let data = UserDefaults.standard.data(forKey: favoritesKey),
           let favorites = try? JSONDecoder().decode([SurfForecast].self, from: data) {
            return favorites
        }
        return []
    }

    //add new surf spot to user favorite
    func addFavorite(forecast: SurfForecast) {
        var favorites = getFavorites()
        if !favorites.contains(where: { $0.spotName == forecast.spotName }) {
            favorites.append(forecast)
            if let data = try? JSONEncoder().encode(favorites) {
                UserDefaults.standard.set(data, forKey: favoritesKey)
            }
        }
    }
    
    //remove surf spot from user favorite
    func removeFavorite(spotName: String) {
        var favorites = getFavorites()
        favorites.removeAll { $0.spotName == spotName }
        if let data = try? JSONEncoder().encode(favorites) {
            UserDefaults.standard.set(data, forKey: favoritesKey)
        }
    }
    
    //check if a surf spot is in user favorites
    func isFavorite(spotName: String) -> Bool {
        return getFavorites().contains(where: { $0.spotName == spotName })
    }
}
