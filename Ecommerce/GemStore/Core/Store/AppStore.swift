//
//  AppStore.swift
//  Ecommerce
//
//  Created by Imac on 13.01.25.
//

import Foundation
import SwiftUI

@MainActor
final class AppStore: ObservableObject {
    static let shared = AppStore()
    
    @Published private(set) var state = State()
    private let networkService: NetworkServiceProtocol
    
    struct State {
        var isInitialized = false
        var isLoading = false
        var error: Error?
        var bannerImageURL = ""
        var newCollectionImageURL = ""
        var topCollectionImageURL = ""
        var bottomCollectionImageURL = ""
        var featuredProducts: [Product] = []
        var recommendedProducts: [Product] = []
    }
    
    private init(networkService: NetworkServiceProtocol = NetworkService()) {
        self.networkService = networkService
    }
    
    func initialize() async {
        guard !state.isInitialized else { return }
        
        state.isLoading = true
        state.error = nil
        
        do {
            async let bannerURL = networkService.fetchImage(path: "images/HomeBanner.png")
            async let newCollectionURL = networkService.fetchImage(path: "images/HomeBanner1.png")
            async let topCollectionURL = networkService.fetchImage(path: "images/HomeBanner2.png")
            async let bottomCollectionURL = networkService.fetchImage(path: "images/HomeBanner3.png")
            async let products = networkService.fetchProducts()
            
            let (banner, newCollection, topCollection, bottomCollection, allProducts) = try await (
                bannerURL,
                newCollectionURL,
                topCollectionURL,
                bottomCollectionURL,
                products
            )
            
            state.bannerImageURL = banner.absoluteString
            state.newCollectionImageURL = newCollection.absoluteString
            state.topCollectionImageURL = topCollection.absoluteString
            state.bottomCollectionImageURL = bottomCollection.absoluteString
            
            state.featuredProducts = allProducts.filter { $0.section == .featured }
            state.recommendedProducts = allProducts.filter { $0.section == .recommended }
            state.isInitialized = true
            
        } catch {
            state.error = error
        }
        
        state.isLoading = false
    }
    
    func retry() async {
        state.isInitialized = false
        await initialize()
    }
}
