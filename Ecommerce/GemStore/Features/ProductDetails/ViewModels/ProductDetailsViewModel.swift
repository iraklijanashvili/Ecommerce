//
//  ProductDetailsViewModel.swift
//  Ecommerce
//
//  Created by Imac on 21.01.25.
//

import Foundation

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
    
    func selectColor(_ color: ProductColor)
    func selectSize(_ size: String)
    func toggleFavorite()
}

class ProductDetailsViewModel: ProductDetailsViewModelProtocol {
    private(set) var product: Product
    private(set) var selectedColor: ProductColor?
    private(set) var selectedSize: String?
    private let favoritesService: FavoritesService
    
    weak var delegate: ProductDetailsViewModelDelegate?
    
    var isFavorite: Bool {
        favoritesService.isFavorite(productId: product.id)
    }
    
    var availableColors: [ProductColor] {
        product.colors?.compactMap { ProductColor.fromString($0) } ?? []
    }
    
    var availableSizes: [String] {
        product.sizes ?? []
    }
    
    var isAddToCartEnabled: Bool {
        guard let selectedColor = selectedColor,
              let selectedSize = selectedSize else {
            return false
        }
        return product.isAvailable(color: selectedColor.rawValue, size: selectedSize)
    }
    
    init(product: Product, favoritesService: FavoritesService = FavoritesServiceImpl.shared) {
        self.product = product
        self.favoritesService = favoritesService
        if let firstColor = availableColors.first {
            self.selectedColor = firstColor
        }
        if let firstSize = availableSizes.first {
            self.selectedSize = firstSize
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
        if isFavorite {
            favoritesService.removeFavorite(productId: product.id)
        } else {
            favoritesService.addFavorite(product: product)
        }
        delegate?.productDetailsViewModelDidUpdate()
    }
} 
