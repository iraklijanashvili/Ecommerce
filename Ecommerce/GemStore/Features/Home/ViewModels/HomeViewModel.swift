//
//  HomeViewModel.swift
//  Ecommerce
//
//  Created by Imac on 16.01.25.
//


import Foundation
import Combine

class HomeViewModel: ObservableObject {
    @Published private(set) var banners: [Banner] = []
    @Published private(set) var categories: [Category] = []
    @Published private(set) var products: [Product] = []
    @Published private(set) var isLoading = false
    @Published private(set) var error: Error?
    
    private let firestoreService: FirestoreService
    private var cancellables = Set<AnyCancellable>()
    
    init(firestoreService: FirestoreService = FirestoreServiceImpl()) {
        self.firestoreService = firestoreService
        print("HomeViewModel initialized")
        
        DispatchQueue.main.async {
            Task {
                await self.loadData()
            }
        }
    }
    
    @MainActor
    func loadData() async {
        print("Starting to load data...")
        isLoading = true
        error = nil
        
        do {
            print("Fetching data sequentially...")
            
            let fetchedBanners = try await firestoreService.fetchBanners()
            self.banners = fetchedBanners
            print("Banners loaded: \(fetchedBanners.count)")
            
            let fetchedCategories = try await firestoreService.fetchCategories()
            self.categories = fetchedCategories
            print("Categories loaded: \(fetchedCategories.count)")
            
            let fetchedProducts = try await firestoreService.fetchProducts()
            self.products = fetchedProducts
            print("Products loaded: \(fetchedProducts.count)")
            
        } catch {
            print("Error loading data: \(error)")
            self.error = error
        }
        
        isLoading = false
        print("Loading completed")
    }
    
    var newCollectionBanner: Banner? {
        let banner = banners.first { $0.type == "new_collection" }
        print("New collection banner found: \(banner != nil)")
        return banner
    }
    
    var topCollectionBanner: Banner? {
        let banner = banners.first { $0.type == "top_collection" }
        print("Top collection banner found: \(banner != nil)")
        return banner
    }
    
    var summerCollectionBanner: Banner? {
        let banner = banners.first { $0.type == "summer_collection" }
        print("Summer collection banner found: \(banner != nil)")
        return banner
    }
    
    var featuredProducts: [Product] {
        let featured = firestoreService.getFeaturedProducts(from: products)
        print("Featured products count: \(featured.count)")
        return featured
    }
    
    var recommendedProducts: [Product] {
        let recommended = firestoreService.getRecommendedProducts(from: products)
        print("Recommended products count: \(recommended.count)")
        return recommended
    }
} 
