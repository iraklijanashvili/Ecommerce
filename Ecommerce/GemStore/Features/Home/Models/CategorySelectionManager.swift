//
//  CategorySelectionManager.swift
//  Ecommerce
//
//  Created by Imac on 30.01.25.
//


import Foundation
import SwiftUI
import FirebaseFirestore

class CategorySelectionManager: ObservableObject, CategorySelectionHandler {
    static let shared = CategorySelectionManager()
    
    @Published private(set) var selectedCategory: Category?
    @Published private(set) var categoryIcons: [String: String] = [:]
    
    private let databaseService: DatabaseService
    private let db = Firestore.firestore()
    
    private init(databaseService: DatabaseService = DatabaseServiceImpl()) {
        self.databaseService = databaseService
    }
    
    func selectCategory(_ category: Category) {
        DispatchQueue.main.async {
            self.selectedCategory = category
        }
    }
    
    func clearSelection() {
        DispatchQueue.main.async {
            self.selectedCategory = nil
        }
    }
    
    @MainActor
    func fetchCategoryIcons() async {
        do {
            let categoryIds = ["accessories", "clothing", "collection", "shoes"]
            var icons: [String: String] = [:]
            
            for categoryId in categoryIds {
                let snapshot = try await db.collection("categoryIcons").document(categoryId).getDocument()
                
                if let data = snapshot.data(), let iconUrl = data["iconUrl"] as? String {
                    icons[categoryId] = iconUrl
                }
            }
            
            self.categoryIcons = icons
        } catch {
            print("❌ Error fetching category icons: \(error)")
        }
    }
} 
