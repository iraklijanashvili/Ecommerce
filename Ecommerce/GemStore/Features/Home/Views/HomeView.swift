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
                            await viewModel.loadData()
                        }
                    }
                } else {
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 20) {
                            if !viewModel.categories.isEmpty {
                                HomeCategorySection(categories: viewModel.categories, selectedTab: $selectedTab)
                                    .padding(.top, 65)
                            }
                            
                            if let topCollectionBanner = viewModel.topCollectionBanner {
                                Text("Top Collection")
                                    .font(.headline)
                                    .foregroundColor(.black)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.horizontal)
                                
                                BannerView(banner: topCollectionBanner)
                                    .frame(height: 200)
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
                                Text("New Collection")
                                    .font(.headline)
                                    .foregroundColor(.black)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.horizontal)
                                
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
                            
                            if let summerCollectionBanner = viewModel.summerCollectionBanner {
                                Text("Summer Collection")
                                    .font(.headline)
                                    .foregroundColor(.black)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.horizontal)
                                
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
            Spacer()
            
            Text("GemStore")
                .font(.headline)
            
            Spacer()
        }
        .padding()
    }
}
