//
//  HomeCategorySectionViewModel.swift
//  Ecommerce
//
//  Created by Imac on 30.01.25.
//


import Foundation
import Combine

class HomeCategorySectionViewModel: ObservableObject, HomeCategorySectionState, HomeCategorySectionInteractor {
    @Published private(set) var categories: [Category] = []
    @Published private(set) var categoryIcons: [String: String] = [:]
    @Published private(set) var isLoading: Bool = false
    @Published private(set) var error: Error? = nil
    
    private let iconRepository: CategoryIconRepository
    private let selectionHandler: CategorySelectionHandler
    
    init(
        categories: [Category],
        iconRepository: CategoryIconRepository,
        selectionHandler: CategorySelectionHandler
    ) {
        self.categories = categories
        self.iconRepository = iconRepository
        self.selectionHandler = selectionHandler
    }
    
    @MainActor
    func loadCategoryIcons() async {
        isLoading = true
        error = nil
        
        do {
            categoryIcons = try await iconRepository.fetchCategoryIcons()
        } catch {
            self.error = error
        }
        
        isLoading = false
    }
    
    func handleCategorySelection(_ category: Category) {
        selectionHandler.selectCategory(category)
    }
    
    func getIconUrl(for categoryId: String) -> String? {
        return categoryIcons[categoryId]
    }
} 
