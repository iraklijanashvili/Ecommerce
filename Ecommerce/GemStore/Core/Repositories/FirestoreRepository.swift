//
//  FirestoreRepository.swift
//  Ecommerce
//
//  Created by Imac on 16.01.25.
//



import Foundation
import FirebaseFirestore

protocol FirestoreRepository {
    func getBanners() async throws -> [Banner]
    func getProducts() async throws -> [Product]
    func getCategories() async throws -> [Category]
    func getProductsForCategory(_ categoryId: String) async throws -> [Product]
    func fetchCategories() async throws -> [Category]
}

class FirestoreRepositoryImpl: FirestoreRepository {
    private let db = Firestore.firestore()
    
    func getBanners() async throws -> [Banner] {
        print("Fetching banners from Firestore...")
        let snapshot = try await db.collection("banners")
            .whereField("isActive", isEqualTo: true)
            .getDocuments()
        
        print("Got \(snapshot.documents.count) banner documents")
        
        return try snapshot.documents.compactMap { document -> Banner? in
            var data = document.data()
            data["id"] = document.documentID
            
            print("Processing banner document: \(document.documentID)")
            print("Banner data: \(data)")
            
            do {
                let banner = try Firestore.Decoder().decode(Banner.self, from: data)
                print("Successfully decoded banner: \(banner.id)")
                print("Banner type: \(banner.type)")
                print("Banner isActive: \(banner.isActive)")
                return banner
            } catch {
                print("Error decoding banner document \(document.documentID): \(error)")
                throw error
            }
        }
    }
    
    func getProducts() async throws -> [Product] {
        print("Fetching products from Firestore...")
        let snapshot = try await db.collection("products").getDocuments()
        
        print("Got \(snapshot.documents.count) product documents")
        
        return try snapshot.documents.compactMap { document -> Product? in
            var data = document.data()
            data["id"] = document.documentID
            do {
                let product = try Firestore.Decoder().decode(Product.self, from: data)
                print("Successfully decoded product: \(product.id)")
                return product
            } catch {
                print("Error decoding product document \(document.documentID): \(error)")
                throw error
            }
        }
    }
    
    func getCategories() async throws -> [Category] {
        print("Fetching categories from Firestore...")
        let snapshot = try await db.collection("categories").getDocuments()
        
        print("Got \(snapshot.documents.count) category documents")
        
        return try snapshot.documents.compactMap { document -> Category? in
            var data = document.data()
            data["id"] = document.documentID
            do {
                let category = try Firestore.Decoder().decode(Category.self, from: data)
                print("Successfully decoded category: \(category.id)")
                return category
            } catch {
                print("Error decoding category document \(document.documentID): \(error)")
                throw error
            }
        }
    }
    
    func getProductsForCategory(_ categoryId: String) async throws -> [Product] {
        print("Fetching products for category \(categoryId)...")
        let snapshot = try await db.collection("products")
            .whereField("categoryId", isEqualTo: categoryId)
            .getDocuments()
        
        print("Got \(snapshot.documents.count) product documents for category \(categoryId)")
        
        return try snapshot.documents.compactMap { document -> Product? in
            var data = document.data()
            data["id"] = document.documentID
            do {
                let product = try Firestore.Decoder().decode(Product.self, from: data)
                print("Successfully decoded product: \(product.id)")
                return product
            } catch {
                print("Error decoding product document \(document.documentID): \(error)")
                throw error
            }
        }
    }
    
    func fetchCategories() async throws -> [Category] {
        print("Fetching categories...")
        let snapshot = try await db.collection("categories").getDocuments()
        print("Got \(snapshot.documents.count) category documents")
        
        return try snapshot.documents.map { document in
            print("Processing category document: \(document.documentID)")
            var categoryData = document.data()
            categoryData["id"] = document.documentID
            
            // Convert subcategories data
            if let subcategoriesData = categoryData["subcategories"] as? [String: [String: Any]] {
                var processedSubcategories: [String: [String: Any]] = [:]
                
                for (subcategoryId, subcategoryData) in subcategoriesData {
                    var processedSubcategory = subcategoryData
                    processedSubcategory["id"] = subcategoryId
                    processedSubcategories[subcategoryId] = processedSubcategory
                }
                
                categoryData["subcategories"] = processedSubcategories
            }
            
            print("Category data prepared: \(categoryData)")
            let jsonData = try JSONSerialization.data(withJSONObject: categoryData)
            let category = try JSONDecoder().decode(Category.self, from: jsonData)
            print("Successfully decoded category: \(category.name) with \(category.subcategoryArray.count) subcategories")
            return category
        }
    }
} 
