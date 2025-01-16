//
//  CategorySection.swift
//  Ecommerce
//
//  Created by Imac on 13.01.25.
//


import SwiftUI

struct CategorySection: View {
    let categories: [Product.Category]
    
    var body: some View {
        GeometryReader { geometry in
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 20) {
                    ForEach(categories) { category in
                        NavigationLink(destination: CategoryProductsView(category: category)) {
                            CategoryItem(category: category)
                        }
                    }
                }
                .frame(minWidth: geometry.size.width)
                .padding(.horizontal)
            }
        }
        .frame(height: 100)
    }
}

private struct CategoryItem: View {
    let category: Product.Category
    
    var body: some View {
        VStack {
            Circle()
                .fill(Color.gray.opacity(0.1))
                .frame(width: 60, height: 60)
                .overlay(
                    Image(systemName: category.icon)
                        .foregroundColor(.primary)
                )
            
            Text(category.rawValue)
                .font(.caption)
                .foregroundColor(.primary)
        }
    }
}

private struct CategoryProductsView: View {
    let category: Product.Category
    
    var body: some View {
        Text("Products in \(category.rawValue)")
    }
} 
