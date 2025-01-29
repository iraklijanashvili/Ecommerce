//
//  CollectionProductsView.swift
//  Ecommerce
//
//  Created by Imac on 22.01.25.
//

import SwiftUI

struct CollectionProductsView: View {
    let collectionType: String
    let title: String
    let isFromHomePage: Bool
    @StateObject private var viewModel = CollectionProductsViewModel()
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        ScrollView {
            VStack {
                HStack {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.black)
                            .imageScale(.large)
                    }
                    Spacer()
                    Text(title)
                        .font(.headline)
                    Spacer()
                }
                .padding()
                
                if viewModel.isLoading {
                    LoadingView()
                } else if let error = viewModel.error {
                    RetryView(error: error) {
                        Task {
                            print("🔄 Retrying fetch for collectionType: \(collectionType)")
                            await viewModel.fetchProducts(forCollection: collectionType)
                        }
                    }
                } else {
                    if viewModel.products.isEmpty {
                        EmptyStateView(
                            title: "No Products Found",
                            message: "There are no products available in this collection.",
                            systemImage: "doc.text.magnifyingglass"
                        )
                        .onAppear {
                            print("⚠️ Showing empty state for collectionType: \(collectionType)")
                        }
                    } else {
                        LazyVGrid(columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ], spacing: 16) {
                            ForEach(viewModel.products) { product in
                                NavigationLink(destination: SharedProductDetailView(product: product, isFromHomePage: false)) {
                                    ProductCard(product: product)
                                }
                            }
                        }
                        .padding()
                        .onAppear {
                            print("✅ Showing \(viewModel.products.count) products for collectionType: \(collectionType)")
                        }
                    }
                }
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            print("🔵 CollectionProductsView appeared for collectionType: \(collectionType)")
            Task {
                await viewModel.fetchProducts(forCollection: collectionType)
            }
        }
    }
}

private struct CollectionErrorView: View {
    let error: Error
    let retryAction: () -> Void
    
    var body: some View {
        VStack {
            Text("Error: \(error.localizedDescription)")
                .multilineTextAlignment(.center)
                .padding()
            
            Button("Retry") {
                retryAction()
            }
        }
    }
}

private struct CollectionProductCard: View {
    let product: Product
    
    var body: some View {
        VStack(alignment: .leading) {
            AsyncImage(url: URL(string: product.defaultImageUrl)) { phase in
                switch phase {
                case .empty:
                    ProgressView()
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                case .failure(_):
                    Color.gray
                        .overlay(
                            Image(systemName: "photo")
                                .foregroundColor(.white)
                        )
                @unknown default:
                    EmptyView()
                }
            }
            .frame(height: 200)
            .clipped()
            
            Text(product.name)
                .font(.subheadline)
                .foregroundColor(.black)
                .lineLimit(2)
                .padding(.horizontal, 8)
            
            Text(product.formattedPrice)
                .font(.headline)
                .foregroundColor(.black)
                .padding(.horizontal, 8)
                .padding(.bottom, 8)
        }
        .background(Color.white)
        .cornerRadius(10)
        .shadow(radius: 2)
    }
}

struct CollectionProductDetailView: View {
    let product: Product
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                AsyncImage(url: URL(string: product.defaultImageUrl)) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                    case .failure:
                        Color.gray
                            .overlay(
                                Image(systemName: "photo")
                                    .foregroundColor(.white)
                            )
                    @unknown default:
                        EmptyView()
                    }
                }
                .frame(maxHeight: 400)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text(product.name)
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text(product.description)
                        .font(.body)
                        .foregroundColor(.secondary)
                    
                    Text(product.formattedPrice)
                        .font(.title3)
                        .fontWeight(.semibold)
                        .padding(.top, 8)
                }
                .padding()
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }
} 
