//
//  HomeViewModel.swift
//  Ecommerce
//
//  Created by Imac on 13.01.25.
//

import Foundation
import SwiftUI

@MainActor
class HomeViewModel: ObservableObject {
    @Published var banners: [Banner] = []
    @Published var products: [Product] = []
    @Published var categories: [Product.Category] = Product.Category.allCases
    @Published var isLoading = false
    @Published var error: Error?
    
    private let firestoreService: FirestoreService
    
    init(firestoreService: FirestoreService = FirestoreServiceImpl()) {
        self.firestoreService = firestoreService
        loadData()
    }
    
    func loadData() {
        Task {
            await fetchData()
        }
    }
    
    private func fetchData() async {
        isLoading = true
        error = nil
        
        do {
            async let bannersTask = firestoreService.fetchBanners()
            async let productsTask = firestoreService.fetchProducts()
            
            let (fetchedBanners, fetchedProducts) = try await (bannersTask, productsTask)
            
            banners = fetchedBanners
            products = fetchedProducts
            
        } catch {
            self.error = error
        }
        
        isLoading = false
    }
    
    
    var mainBanners: [Banner] {
        banners.filter { $0.linkType == .main }
    }
    
    var newCollectionBanner: Banner? {
        banners.first { $0.linkType == .newCollection }
    }
    
    var topCollectionBanner: Banner? {
        banners.first { $0.linkType == .topCollection }
    }
    
    var summerCollectionBanner: Banner? {
        banners.first { $0.linkType == .summerCollection }
    }
    
    var featuredProducts: [Product] {
        firestoreService.getFeaturedProducts(from: products)
    }
    
    var recommendedProducts: [Product] {
        firestoreService.getRecommendedProducts(from: products)
    }
}
