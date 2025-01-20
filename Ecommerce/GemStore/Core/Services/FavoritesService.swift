//
//  FavoritesService.swift
//  Ecommerce
//
//  Created by Imac on 21.01.25.
//

import Foundation

protocol FavoritesService {
    func addFavorite(product: Product)
    func removeFavorite(productId: String)
    func isFavorite(productId: String) -> Bool
    func getFavorites() -> [Product]
}

class FavoritesServiceImpl: FavoritesService {
    static let shared = FavoritesServiceImpl()
    
    private let userDefaults = UserDefaults.standard
    private let favoritesKey = "favorites"
    
    private init() {}
    
    func addFavorite(product: Product) {
        var favorites = getFavorites()
        if !favorites.contains(where: { $0.id == product.id }) {
            favorites.append(product)
            saveFavorites(favorites)
        }
    }
    
    func removeFavorite(productId: String) {
        var favorites = getFavorites()
        favorites.removeAll { $0.id == productId }
        saveFavorites(favorites)
    }
    
    func isFavorite(productId: String) -> Bool {
        let favorites = getFavorites()
        return favorites.contains { $0.id == productId }
    }
    
    func getFavorites() -> [Product] {
        guard let data = userDefaults.data(forKey: favoritesKey),
              let favorites = try? JSONDecoder().decode([Product].self, from: data) else {
            return []
        }
        return favorites
    }
    
    private func saveFavorites(_ favorites: [Product]) {
        if let data = try? JSONEncoder().encode(favorites) {
            userDefaults.set(data, forKey: favoritesKey)
        }
    }
}
