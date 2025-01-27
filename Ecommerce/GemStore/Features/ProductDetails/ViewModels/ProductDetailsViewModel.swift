//
//  ProductDetailsViewModel.swift
//  Ecommerce
//
//  Created by Imac on 21.01.25.
//

import Foundation
import Combine

protocol ProductDetailsViewModelDelegate: AnyObject {
    func productDetailsViewModelDidUpdate()
}

protocol ProductDetailsViewModelProtocol {
    var product: Product { get }
    var selectedColor: ProductColor? { get }
    var selectedSize: String? { get }
    var availableColors: [ProductColor] { get }
    var availableSizes: [String] { get }
    var isAddToCartEnabled: Bool { get }
    var isFavorite: Bool { get }
    var isAddToCartEnabledPublisher: AnyPublisher<Bool, Never> { get }
    
    func selectColor(_ color: ProductColor)
    func selectSize(_ size: String)
    func toggleFavorite()
    func addToCart()
}

class ProductDetailsViewModel: ProductDetailsViewModelProtocol, ObservableObject {
    @Published var product: Product
    @Published var selectedColor: ProductColor?
    @Published var selectedSize: String?
    @Published var isFavorite: Bool = false
    @Published var isAddToCartEnabled: Bool = false
    
    private let favoritesService: FavoritesService
    private let cartService: CartServiceProtocol
    private var cancellables = Set<AnyCancellable>()
    
    weak var delegate: ProductDetailsViewModelDelegate?
    
    var availableColors: [ProductColor] {
        product.colors?.compactMap { ProductColor.fromString($0) } ?? []
    }
    
    var availableSizes: [String] {
        product.sizes ?? []
    }
    
    var isAddToCartEnabledPublisher: AnyPublisher<Bool, Never> {
        $isAddToCartEnabled.eraseToAnyPublisher()
    }
    
    init(
        product: Product,
        favoritesService: FavoritesService = FavoritesServiceImpl.shared,
        cartService: CartServiceProtocol = CartServiceImpl.shared
    ) {
        self.product = product
        self.favoritesService = favoritesService
        self.cartService = cartService
        
        Task {
            await checkFavoriteStatus()
        }
        
        setupBindings()
    }
    
    private func setupBindings() {
        Publishers.CombineLatest($selectedColor, $selectedSize)
            .map { color, size in
                guard let color = color,
                      let size = size,
                      let inventory = self.product.inventory,
                      let sizeInventory = inventory[color.rawValue],
                      let quantity = sizeInventory[size] else {
                    return false
                }
                return quantity > 0
            }
            .receive(on: DispatchQueue.main)
            .assign(to: &$isAddToCartEnabled)
    }
    
    func checkFavoriteStatus() async {
        do {
            let isFavorite = try await favoritesService.isFavorite(productId: product.id)
            await MainActor.run {
                self.isFavorite = isFavorite
            }
        } catch {
            print("Error checking favorite status: \(error)")
            await MainActor.run {
                self.isFavorite = false
            }
        }
    }
    
    func selectColor(_ color: ProductColor) {
        selectedColor = color
        delegate?.productDetailsViewModelDidUpdate()
    }
    
    func selectSize(_ size: String) {
        selectedSize = size
        delegate?.productDetailsViewModelDidUpdate()
    }
    
    func toggleFavorite() {
        Task {
            do {
                if isFavorite {
                    try await favoritesService.removeFavorite(productId: product.id)
                } else {
                    try await favoritesService.addFavorite(product: product)
                }
                await MainActor.run {
                    isFavorite.toggle()
                    delegate?.productDetailsViewModelDidUpdate()
                }
            } catch {
                print("Error toggling favorite: \(error)")
            }
        }
    }
    
    func addToCart() {
        guard let color = selectedColor,
              let size = selectedSize,
              isAddToCartEnabled else { return }
        
        cartService.addToCart(
            product: product,
            quantity: 1,
            size: size,
            color: color
        )
    }
} 
