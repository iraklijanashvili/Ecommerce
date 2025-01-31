//
//  HomeView.swift
//  Ecommerce
//
//  Created by Imac on 13.01.25.
//


import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()
    @Binding var selectedTab: Int
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .top) {
                if viewModel.isLoading {
                    ProgressView()
                } else if let error = viewModel.error {
                    SharedErrorView(error: error) {
                        Task {
                            await viewModel.loadData(forceReload: true)
                        }
                    }
                } else {
                    ScrollView(showsIndicators: false) {
                        LazyVStack(spacing: 20) {
                            if !viewModel.categories.isEmpty {
                                HomeCategorySection(categories: viewModel.categories, selectedTab: $selectedTab)
                                    .padding(.top, 65)
                            }
                            
                            Group {
                                if let topCollectionBanner = viewModel.topCollectionBanner {
                                    VStack(alignment: .leading, spacing: 8) {
                                        Text("Top Collection")
                                            .font(.headline)
                                            .foregroundColor(.black)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            .padding(.horizontal)
                                        
                                        BannerView(banner: topCollectionBanner)
                                            .frame(height: 200)
                                            .padding(.horizontal)
                                    }
                                }
                                
                                if !viewModel.featuredProducts.isEmpty {
                                    ProductSection(
                                        title: "Featured Products",
                                        products: viewModel.featuredProducts,
                                        style: .featured
                                    )
                                }
                                
                                if let newCollectionBanner = viewModel.newCollectionBanner {
                                    VStack(alignment: .leading, spacing: 8) {
                                        Text("New Collection")
                                            .font(.headline)
                                            .foregroundColor(.black)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            .padding(.horizontal)
                                        
                                        BannerView(banner: newCollectionBanner)
                                            .frame(height: 200)
                                            .padding(.horizontal)
                                    }
                                }
                                
                                if !viewModel.recommendedProducts.isEmpty {
                                    ProductSection(
                                        title: "Recommended",
                                        products: viewModel.recommendedProducts,
                                        style: .compact
                                    )
                                }
                                
                                if let summerCollectionBanner = viewModel.summerCollectionBanner {
                                    VStack(alignment: .leading, spacing: 8) {
                                        Text("Summer Collection")
                                            .font(.headline)
                                            .foregroundColor(.black)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            .padding(.horizontal)
                                        
                                        BannerView(banner: summerCollectionBanner)
                                            .frame(height: 200)
                                            .padding(.horizontal)
                                    }
                                }
                            }
                        }
                    }
                    .refreshable {
                        await viewModel.loadData(forceReload: true)
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
        .task {
            await viewModel.loadData()
        }
    }
}

private struct CustomNavigationBar: View {
    var body: some View {
        HStack {
            Spacer()
            
            Text("GemStore")
                .font(.headline)
            
            Spacer()
        }
        .padding()
    }
}
