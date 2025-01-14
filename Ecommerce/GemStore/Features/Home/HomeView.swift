//
//  HomeView.swift
//  Ecommerce
//
//  Created by Imac on 13.01.25.
//


import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel: HomeViewModel = HomeViewModel()
    
    var body: some View {
        NavigationView {
            ZStack {
                if viewModel.isLoading {
                    ProgressView()
                } else if let error = viewModel.error {
                    ErrorView(error: error) {
                        Task {
                            await viewModel.retry()
                        }
                    }
                } else {
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 20) {
                            CategorySection(categories: viewModel.categories)
                                .padding(.top, 70)
                            
                            BannerView(imageURL: viewModel.bannerImageURL)
                                .padding(.horizontal)
                            ProductSection(
                                title: "Featured Products",
                                products: viewModel.featuredProducts
                            )
                            
                            NewCollectionView(imageURL: viewModel.newCollectionImageURL)
                            
                            ProductSection(
                                title: "Recommended",
                                products: viewModel.recommendedProducts,
                                style: .compact
                            )
                            
                            TopCollectionView(
                                topImageURL: viewModel.topCollectionImageURL,
                                bottomImageURL: viewModel.bottomCollectionImageURL
                            )
                        }
                    }
                }
                
                VStack {
                    CustomNavigationBar()
                    Spacer()
                }
            }
            .navigationBarHidden(true)
        }
    }
}


private struct CustomNavigationBar: View {
    var body: some View {
        HStack {
            MenuButton()
            
            Spacer()
            
            Text("GemStore")
                .font(.headline)
            
            Spacer()
            
            NotificationButton()
        }
        .padding()
        .background(Color(UIColor.systemBackground))
        .shadow(radius: 2)
    }
}

private struct MenuButton: View {
    var body: some View {
        Button(action: {}) {
            Image(systemName: "line.horizontal.3")
                .foregroundColor(.primary)
        }
    }
}

private struct ErrorView: View {
    let error: Error
    let retryAction: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.largeTitle)
                .foregroundColor(.red)
            
            Text("Something went wrong")
                .font(.headline)
            
            Text(error.localizedDescription)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Button("Try Again") {
                retryAction()
            }
            .buttonStyle(.bordered)
        }
        .padding()
    }
} 
