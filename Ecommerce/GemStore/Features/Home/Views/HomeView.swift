//
//  HomeView.swift
//  Ecommerce
//
//  Created by Imac on 13.01.25.
//


import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .top) {
                if viewModel.isLoading {
                    ProgressView()
                } else if let error = viewModel.error {
                    ErrorView(error: error) {
                        viewModel.loadData()
                    }
                } else {
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 20) {
                            CategorySection(categories: viewModel.categories)
                                .padding(.top, 65)
                            
                            if !viewModel.mainBanners.isEmpty {
                                TabView {
                                    ForEach(viewModel.mainBanners) { banner in
                                        BannerView(banner: banner)
                                    }
                                }
                                .frame(height: 200)
                                .tabViewStyle(.page)
                                .padding(.horizontal)
                            }
                            
                            if !viewModel.featuredProducts.isEmpty {
                                ProductSection(
                                    title: "Featured Products",
                                    products: viewModel.featuredProducts,
                                    style: .featured
                                )
                            }
                            
                            if let newCollectionBanner = viewModel.newCollectionBanner {
                                NewCollectionView(imageURL: newCollectionBanner.imageUrl)
                                    .padding(.horizontal)
                            }
                            
                            if !viewModel.recommendedProducts.isEmpty {
                                ProductSection(
                                    title: "Recommended",
                                    products: viewModel.recommendedProducts,
                                    style: .compact
                                )
                            }
                            
                            if let topCollectionBanner = viewModel.topCollectionBanner {
                                TopCollectionView(
                                    topImageURL: topCollectionBanner.imageUrl
                                )
                                .padding(.horizontal)
                            }
                            
                            if let summerCollectionBanner = viewModel.summerCollectionBanner {
                                NewCollectionView(imageURL: summerCollectionBanner.imageUrl)
                                    .padding(.horizontal)
                            }
                        }
                    }
                }
                
                VStack(spacing: 0) {
                    Color(UIColor.systemBackground)
                        .frame(height: geometry.safeAreaInsets.top)
                    
                    CustomNavigationBar()
                        .background(Color(UIColor.systemBackground))
                        .shadow(radius: 2)
                }
                .frame(maxWidth: .infinity)
                .ignoresSafeArea(edges: .top)
            }
        }
        .navigationBarHidden(true)
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

private struct NotificationButton: View {
    var body: some View {
        Button(action: {}) {
            Image(systemName: "bell")
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
