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
    let includeTypes: [String]?
    @StateObject private var viewModel = CollectionProductsViewModel()
    @Environment(\.presentationMode) var presentationMode
    
    init(collectionType: String, title: String, isFromHomePage: Bool, includeTypes: [String]? = nil) {
        self.collectionType = collectionType
        self.title = title
        self.isFromHomePage = isFromHomePage
        self.includeTypes = includeTypes
    }
    
    var body: some View {
        ScrollView {
            VStack {
                HStack {
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            presentationMode.wrappedValue.dismiss()
                        }
                    }) {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.black)
                            .imageScale(.large)
                            .padding(8)
                            .background(Color.white)
                            .clipShape(Circle())
                            .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
                    }
                    .buttonStyle(ScaleButtonStyle())
                    
                    Spacer()
                    Text(title)
                        .font(.headline)
                    Spacer()
                }
                .padding()
                
                if viewModel.isLoading {
                    LoadingView()
                        .transition(.opacity)
                } else if let error = viewModel.error {
                    RetryView(error: error) {
                        Task {
                            print("🔄 Retrying fetch for collectionType: \(collectionType)")
                            if let types = includeTypes {
                                await viewModel.fetchProducts(forCollections: types)
                            } else {
                                await viewModel.fetchProducts(forCollection: collectionType)
                            }
                        }
                    }
                    .transition(.opacity)
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
                        .transition(.opacity)
                    } else {
                        LazyVGrid(columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ], spacing: 16) {
                            ForEach(viewModel.products) { product in
                                NavigationLink(destination: SharedProductDetailView(product: product, isFromHomePage: false)) {
                                    ProductCard(product: product)
                                        .transition(.opacity)
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
                if let types = includeTypes {
                    await viewModel.fetchProducts(forCollections: types)
                } else {
                    await viewModel.fetchProducts(forCollection: collectionType)
                }
            }
        }
    }
}

struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
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
