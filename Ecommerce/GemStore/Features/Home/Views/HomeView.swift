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
                    SharedErrorView(error: error) {
                        Task {
                            await viewModel.loadData()
                        }
                    }
                } else {
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 20) {
                            if !viewModel.categories.isEmpty {
                                HomeCategorySection(categories: viewModel.categories)
                                    .padding(.top, 65)
                            }
                            
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
                                BannerView(banner: newCollectionBanner)
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
                                Text("Top Collection")
                                    .font(.headline)
                                    .foregroundColor(.black)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.horizontal)
                                
                                BannerView(banner: topCollectionBanner)
                                    .padding(.horizontal)
                            }
                            
                            if let summerCollectionBanner = viewModel.summerCollectionBanner {
                                BannerView(banner: summerCollectionBanner)
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
