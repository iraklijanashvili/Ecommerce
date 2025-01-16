//
//  ProductSection.swift
//  Ecommerce
//
//  Created by Imac on 13.01.25.
//

import SwiftUI

struct ProductSection: View {
    let title: String
    let products: [Product]
    let style: Style
    
    enum Style {
        case regular
        case compact
        case featured
    }
    
    init(
        title: String,
        products: [Product],
        style: Style = .regular
    ) {
        self.title = title
        self.products = products
        self.style = style
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            SectionHeader(title: title)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 15) {
                    ForEach(products) { product in
                        NavigationLink(destination: ProductDetailView(product: product)) {
                            switch style {
                            case .regular:
                                RegularProductCard(product: product)
                            case .compact:
                                CompactProductCard(product: product)
                            case .featured:
                                FeaturedProductCard(product: product)
                            }
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
    }
}

private struct SectionHeader: View {
    let title: String
    
    var body: some View {
        HStack {
            Text(title)
                .font(.headline)
                .foregroundColor(.black)
            Spacer()
            NavigationLink("Show all", destination: ProductListView())
                .font(.caption)
                .foregroundColor(.gray)
        }
        .padding(.horizontal)
    }
}

private struct RegularProductCard: View {
    let product: Product
    
    var body: some View {
        VStack(alignment: .leading) {
            AsyncImage(url: URL(string: product.images)) { phase in
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
            .frame(width: 150, height: 200)
            .clipped()
            
            Text(product.name)
                .font(.caption)
                .foregroundColor(.black)
                .lineLimit(1)
            
            Text(product.formattedPrice)
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(.black)
        }
        .frame(width: 150)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.gray.opacity(0.2), lineWidth: 0.5)
        )
        .background(Color.white)
        .cornerRadius(10)
        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
}

private struct CompactProductCard: View {
    let product: Product
    
    var body: some View {
        HStack(spacing: 0) {
            AsyncImage(url: URL(string: product.images)) { phase in
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
            .frame(width: 66, height: 66)
            .clipped()
            
            VStack(alignment: .leading, spacing: 4) {
                Text(product.name)
                    .font(.system(size: 14))
                    .foregroundColor(.black)
                    .lineLimit(2)
                
                Text(product.formattedPrice)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.black)
            }
            .padding(.horizontal, 12)
            
            Spacer()
        }
        .frame(width: 213, height: 66)
        .background(Color.white)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.gray.opacity(0.2), lineWidth: 0.5)
        )
        .cornerRadius(8)
        .shadow(color: Color.black.opacity(0.1), radius: 3, x: 0, y: 2)
    }
}

private struct FeaturedProductCard: View {
    let product: Product
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            AsyncImage(url: URL(string: product.images)) { phase in
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
            .frame(width: 180, height: 240)
            .clipped()
            
            VStack(alignment: .leading, spacing: 4) {
                Text(product.name)
                    .font(.system(size: 16))
                    .foregroundColor(.black)
                    .lineLimit(2)
                
                Text(product.formattedPrice)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.black)
            }
            .padding(.horizontal, 8)
        }
        .frame(width: 180)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.gray.opacity(0.2), lineWidth: 0.5)
        )
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
}

private struct ProductDetailView: View {
    let product: Product
    
    var body: some View {
        Text("Product Detail: \(product.name)")
    }
}

private struct ProductListView: View {
    var body: some View {
        Text("All Products")
    }
} 
