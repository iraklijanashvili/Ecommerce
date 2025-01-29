//
//  FilterViewModel.swift
//  Ecommerce
//
//  Created by Imac on 21.01.25.
//

import Foundation
import Combine

protocol FilterViewModelDelegate: AnyObject {
    func filterViewModelDidUpdateFilter()
    func filterViewModelDidReset()
    func filterViewModelDidApply(_ filter: FilterOptions)
}

class FilterViewModel {
    private(set) var currentFilter: FilterOptions
    private(set) var selectedColors: Set<ProductColor>
    private(set) var selectedCategories: Set<ProductCategory>
    private(set) var currentPriceRange: PriceRange
    private(set) var currentSortOption: SortOption
    
    weak var delegate: FilterViewModelDelegate?
    
    var categoriesButtonTitle: String {
        if selectedCategories.isEmpty {
            return "Select Categories"
        } else if selectedCategories.count == 1 {
            return selectedCategories.first?.displayName ?? ""
        } else {
            return "\(selectedCategories.count) Categories"
        }
    }
    
    var priceRangeText: String {
        return "$\(Int(currentPriceRange.min)) - $\(Int(currentPriceRange.max))"
    }
    
    var availableCategories: [ProductCategory] {
        return ProductCategory.allCases
    }
    
    var availableColors: [ProductColor] {
        return ProductColor.allCases
    }
    
    init(currentFilter: FilterOptions) {
        self.currentFilter = currentFilter
        self.selectedColors = currentFilter.selectedColors
        self.selectedCategories = currentFilter.selectedCategories
        self.currentPriceRange = currentFilter.priceRange
        self.currentSortOption = currentFilter.sortBy
    }
    
    func toggleColor(_ color: ProductColor) {
        if selectedColors.contains(color) {
            selectedColors.remove(color)
        } else {
            selectedColors.insert(color)
        }
        delegate?.filterViewModelDidUpdateFilter()
    }
    
    func toggleCategory(_ category: ProductCategory) {
        if selectedCategories.contains(category) {
            selectedCategories.remove(category)
        } else {
            selectedCategories.insert(category)
        }
        delegate?.filterViewModelDidUpdateFilter()
    }
    
    func updatePriceRange(_ value: Float) {
        currentPriceRange.max = Double(value)
        delegate?.filterViewModelDidUpdateFilter()
    }
    
    func updateSortOption(_ option: SortOption) {
        currentSortOption = option
        delegate?.filterViewModelDidUpdateFilter()
    }
    
    func isColorSelected(_ color: ProductColor) -> Bool {
        return selectedColors.contains(color)
    }
    
    func isCategorySelected(_ category: ProductCategory) -> Bool {
        return selectedCategories.contains(category)
    }
    
    func reset() {
        selectedColors.removeAll()
        selectedCategories.removeAll()
        currentPriceRange = PriceRange(min: 0, max: 1000)
        currentSortOption = .none
        delegate?.filterViewModelDidReset()
    }
    
    func apply() {
        let filter = FilterOptions(
            priceRange: currentPriceRange,
            selectedColors: selectedColors,
            selectedCategories: selectedCategories,
            sortBy: currentSortOption
        )
        delegate?.filterViewModelDidApply(filter)
    }
} 
