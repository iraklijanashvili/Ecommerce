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
    var currentImageUrl: String { get }
    
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
    @Published private(set) var currentImageUrl: String
    
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
        
        if let defaultImageUrl = product.imageUrl {
            self.currentImageUrl = defaultImageUrl
        } else {
            self.currentImageUrl = ""
        }
        
        if let firstColor = product.colors?.first.flatMap(ProductColor.fromString) {
            self.selectedColor = firstColor
            if let colorVariant = product.colorVariants?[firstColor.rawValue] {
                self.currentImageUrl = colorVariant.image
            }
            
            if let sizes = product.sizes {
                for size in sizes {
                    if let colorVariant = product.colorVariants?[firstColor.rawValue],
                       let quantity = colorVariant.inventory[size],
                       quantity > 0 {
                        self.selectedSize = size
                        break
                    } else if let inventory = product.inventory?[firstColor.rawValue],
                              let quantity = inventory[size],
                              quantity > 0 {
                        self.selectedSize = size
                        break
                    }
                }
            }
        }
        
        Task {
            await checkFavoriteStatus()
        }
        
        setupBindings()
    }
    
    private func setupBindings() {
        Publishers.CombineLatest($selectedColor, $selectedSize)
            .map { [weak self] color, size in
                guard let self = self,
                      let color = color,
                      let size = size else {
                    return false
                }
                
                if let colorVariant = self.product.colorVariants?[color.rawValue],
                   let quantity = colorVariant.inventory[size] {
                    return quantity > 0
                }
                
                if let inventory = self.product.inventory,
                   let sizeInventory = inventory[color.rawValue],
                   let quantity = sizeInventory[size] {
                    return quantity > 0
                }
                
                return false
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
        
        if let colorVariant = product.colorVariants?[color.rawValue] {
            currentImageUrl = colorVariant.image
        } else {
            currentImageUrl = product.imageUrl ?? ""
        }
        
        if let sizes = product.sizes {
            for size in sizes {
                if let colorVariant = product.colorVariants?[color.rawValue],
                   let quantity = colorVariant.inventory[size],
                   quantity > 0 {
                    selectedSize = size
                    break
                } else if let inventory = product.inventory?[color.rawValue],
                          let quantity = inventory[size],
                          quantity > 0 {
                    selectedSize = size
                    break
                }
            }
        }
        
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
