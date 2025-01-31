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
    private var hasLoadedData = false
    
    init(firestoreService: FirestoreService = FirestoreServiceImpl()) {
        self.firestoreService = firestoreService
        print("HomeViewModel initialized")
    }
    
    deinit {
        print("HomeViewModel deinitialized")
        cancellables.removeAll()
    }
    
    @MainActor
    func loadData(forceReload: Bool = false) async {
        if !forceReload && hasLoadedData {
            return
        }
        
        print("Starting to load data...")
        isLoading = true
        error = nil
        
        do {
            print("Fetching data in parallel...")
            
            async let bannersTask = firestoreService.fetchBanners()
            async let categoriesTask = firestoreService.fetchCategories()
            async let productsTask = firestoreService.fetchProducts()
            
            let (fetchedBanners, fetchedCategories, fetchedProducts) = try await (bannersTask, categoriesTask, productsTask)
            
            self.banners = fetchedBanners
            print("Banners loaded: \(fetchedBanners.count)")
            
            self.categories = fetchedCategories
            print("Categories loaded: \(fetchedCategories.count)")
            
            self.products = fetchedProducts
            print("Products loaded: \(fetchedProducts.count)")
            
            hasLoadedData = true
            
        } catch {
            print("Error loading data: \(error)")
            self.error = error
            hasLoadedData = false
        }
        
        isLoading = false
        print("Loading completed")
    }
    
    @MainActor
    func reloadBanners() async {
        do {
            let fetchedBanners = try await firestoreService.fetchBanners()
            self.banners = fetchedBanners
            print("Banners reloaded: \(fetchedBanners.count)")
        } catch {
            print("Error reloading banners: \(error)")
        }
    }
    
    var newCollectionBanner: Banner? {
        let banner = banners.first { $0.type == "new_collection" }
        return banner
    }
    
    var topCollectionBanner: Banner? {
        let banner = banners.first { $0.type == "top_collection" }
        return banner
    }
    
    var summerCollectionBanner: Banner? {
        let banner = banners.first { $0.type == "summer_collection" }
        return banner
    }
    
    var featuredProducts: [Product] {
        let featured = firestoreService.getFeaturedProducts(from: products)
        return featured
    }
    
    var recommendedProducts: [Product] {
        let recommended = firestoreService.getRecommendedProducts(from: products)
        return recommended
    }
} 
