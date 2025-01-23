//
//  WishlistViewModel.swift
//  Ecommerce
//
//  Created by Imac on 23.01.25.
//

import Foundation
import Combine

protocol WishlistViewModelProtocol {
    var products: [Product] { get }
    var productsPublisher: AnyPublisher<[Product], Never> { get }
    var isLoading: Bool { get }
    var isLoadingPublisher: AnyPublisher<Bool, Never> { get }
    
    func removeFromWishlist(productId: String) async
}

class WishlistViewModel: WishlistViewModelProtocol, ObservableObject {
    @Published private(set) var products: [Product] = []
    @Published private(set) var isLoading: Bool = false
    
    var productsPublisher: AnyPublisher<[Product], Never> {
        $products.eraseToAnyPublisher()
    }
    
    var isLoadingPublisher: AnyPublisher<Bool, Never> {
        $isLoading.eraseToAnyPublisher()
    }
    
    private let favoritesService: FavoritesService
    private var cancellables = Set<AnyCancellable>()
    
    init(favoritesService: FavoritesService = FavoritesServiceImpl.shared) {
        self.favoritesService = favoritesService
        setupBindings()
    }
    
    private func setupBindings() {
        isLoading = true
        
        favoritesService.favoritesPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] products in
                self?.isLoading = false
                self?.products = products
            }
            .store(in: &cancellables)
    }
    
    func removeFromWishlist(productId: String) async {
        do {
            try await favoritesService.removeFavorite(productId: productId)
        } catch {
            print("Error removing from wishlist: \(error)")
        }
    }
} 
