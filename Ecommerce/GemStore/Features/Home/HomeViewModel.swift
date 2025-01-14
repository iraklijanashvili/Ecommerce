//
//  HomeViewModel.swift
//  Ecommerce
//
//  Created by Imac on 13.01.25.
//

import Foundation
import SwiftUI
import Combine

@MainActor
protocol HomeViewModelProtocol: ObservableObject {
    var isLoading: Bool { get }
    var error: Error? { get }
    var categories: [Product.Category] { get }
    var bannerImageURL: String { get }
    var featuredProducts: [Product] { get }
    var recommendedProducts: [Product] { get }
    var newCollectionImageURL: String { get }
    var topCollectionImageURL: String { get }
    var bottomCollectionImageURL: String { get }
    
    func retry() async
}

@MainActor
final class HomeViewModel: HomeViewModelProtocol {
    @Published private(set) var isLoading: Bool = false
    @Published private(set) var error: Error?
    @Published private(set) var categories: [Product.Category] = Product.Category.allCases
    @Published private(set) var bannerImageURL: String = ""
    @Published private(set) var featuredProducts: [Product] = []
    @Published private(set) var recommendedProducts: [Product] = []
    @Published private(set) var newCollectionImageURL: String = ""
    @Published private(set) var topCollectionImageURL: String = ""
    @Published private(set) var bottomCollectionImageURL: String = ""
    
    private let store: AppStore
    private var cancellables = Set<AnyCancellable>()
    
    init(store: AppStore = .shared) {
        self.store = store
        setupBindings()
    }
    
    private func setupBindings() {
        store.$state
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                guard let self else { return }
                self.isLoading = state.isLoading
                self.error = state.error
                self.bannerImageURL = state.bannerImageURL
                self.featuredProducts = state.featuredProducts
                self.recommendedProducts = state.recommendedProducts
                self.newCollectionImageURL = state.newCollectionImageURL
                self.topCollectionImageURL = state.topCollectionImageURL
                self.bottomCollectionImageURL = state.bottomCollectionImageURL
            }
            .store(in: &cancellables)
    }
    
    func retry() async {
        await store.retry()
    }
} 
