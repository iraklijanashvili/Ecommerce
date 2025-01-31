//
//  HomeCategoryModels.swift
//  Ecommerce
//
//  Created by Imac on 30.01.25.
//


import Foundation

protocol CategoryIconRepository {
    func fetchCategoryIcons() async throws -> [String: String]
}

protocol CategorySelectionHandler {
    func selectCategory(_ category: Category)
    var selectedCategory: Category? { get }
}

protocol HomeCategorySectionState {
    var categories: [Category] { get }
    var categoryIcons: [String: String] { get }
    var isLoading: Bool { get }
    var error: Error? { get }
}

protocol HomeCategorySectionInteractor {
    func loadCategoryIcons() async
    func handleCategorySelection(_ category: Category)
} 
