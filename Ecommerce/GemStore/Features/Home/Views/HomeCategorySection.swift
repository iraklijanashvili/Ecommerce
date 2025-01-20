//
//  HomeCategorySection.swift
//  Ecommerce
//
//  Created by Imac on 13.01.25.
//

import SwiftUI

struct HomeCategorySection: View {
    let categories: [Category]
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 16) {
                ForEach(categories) { category in
                    NavigationLink(destination: CategoryProductsView(categoryId: category.id, title: category.name)) {
                        CategoryCard(category: category)
                    }
                }
            }
            .padding(.horizontal)
        }
    }
}

private struct CategoryCard: View {
    let category: Category
    
    var body: some View {
        VStack {
            AsyncImage(url: URL(string: category.imageUrl)) { phase in
                switch phase {
                case .empty:
                    ProgressView()
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
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
            .frame(width: 100, height: 100)
            .clipShape(Circle())
            
            Text(category.name)
                .font(.caption)
                .foregroundColor(.black)
                .lineLimit(2)
                .multilineTextAlignment(.center)
        }
        .frame(width: 100)
    }
}

struct CategoryProductsView: View {
    let categoryId: String
    let title: String
    @StateObject private var viewModel = DiscoverViewModel()
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 16) {
                ForEach(viewModel.products) { product in
                    ProductCard(product: product)
                }
            }
            .padding()
        }
        .navigationTitle(title)
        .onAppear {
            viewModel.fetchProducts(for: categoryId)
        }
    }
} 
