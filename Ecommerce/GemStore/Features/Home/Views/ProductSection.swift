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
            SectionHeader(title: title, style: style)
            
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(alignment: .top, spacing: 16) {
                    ForEach(products) { product in
                        NavigationLink(destination: SharedProductDetailView(product: product, isFromHomePage: true)) {
                            switch style {
                            case .regular:
                                RegularProductCard(product: product)
                                    .frame(width: 150)
                                    .fixedSize(horizontal: true, vertical: false)
                            case .compact:
                                CompactProductCard(product: product)
                                    .frame(width: 213)
                                    .fixedSize(horizontal: true, vertical: false)
                            case .featured:
                                FeaturedProductCard(product: product)
                                    .frame(width: 180)
                                    .fixedSize(horizontal: true, vertical: false)
                            }
                        }
                    }
                }
                .padding(.horizontal, 16)
            }
        }
    }
}

private struct SectionHeader: View {
    let title: String
    let style: ProductSection.Style
    
    var body: some View {
        HStack {
            Text(title)
                .font(.headline)
                .foregroundColor(.black)
            Spacer()
            let collectionType = style == .featured ? "featured" : "recommended"
            NavigationLink(
                destination: CollectionProductsView(
                    collectionType: collectionType,
                    title: title,
                    isFromHomePage: true
                )
            ) {
                Text("Show all")
                    .font(.caption)
                    .foregroundColor(.gray)
                    .padding(.vertical, 4)
                    .padding(.horizontal, 8)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(12)
            }
            .buttonStyle(ScaleButtonStyle())
            .onAppear {
                print("🔍 Navigation Link created with collectionType: \(collectionType)")
            }
        }
        .padding(.horizontal)
    }
}

private struct RegularProductCard: View {
    let product: Product
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            AsyncImage(url: URL(string: product.defaultImageUrl)) { phase in
                switch phase {
                case .empty:
                    ProgressView()
                        .frame(width: 150, height: 200)
                        .background(Color.gray.opacity(0.1))
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFill()
                        .frame(width: 150, height: 200)
                        .clipped()
                case .failure(_):
                    Color.gray
                        .overlay(
                            Image(systemName: "photo")
                                .foregroundColor(.white)
                        )
                        .frame(width: 150, height: 200)
                @unknown default:
                    EmptyView()
                        .frame(width: 150, height: 200)
                }
            }
            .frame(width: 150, height: 200)
            .clipped()
            
            VStack(alignment: .leading, spacing: 4) {
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
            .padding(.horizontal, 8)
        }
        .frame(width: 150, height: 260)
        .background(Color.white)
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.gray.opacity(0.2), lineWidth: 0.5)
        )
        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
        .padding(.bottom, 8)
    }
}

private struct CompactProductCard: View {
    let product: Product
    
    var body: some View {
        HStack(spacing: 0) {
            AsyncImage(url: URL(string: product.defaultImageUrl)) { phase in
                switch phase {
                case .empty:
                    ProgressView()
                        .frame(width: 66, height: 66)
                        .background(Color.gray.opacity(0.1))
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 66, height: 66)
                case .failure(_):
                    Color.gray
                        .overlay(
                            Image(systemName: "photo")
                                .foregroundColor(.white)
                        )
                        .frame(width: 66, height: 66)
                @unknown default:
                    EmptyView()
                        .frame(width: 66, height: 66)
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
            AsyncImage(url: URL(string: product.defaultImageUrl)) { phase in
                switch phase {
                case .empty:
                    ProgressView()
                        .frame(maxWidth: 180, maxHeight: 240)
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFill()
                        .frame(maxWidth: 180, maxHeight: 240)
                        .clipped()
                case .failure(_):
                    Color.gray
                        .overlay(
                            Image(systemName: "photo")
                                .foregroundColor(.white)
                        )
                        .frame(maxWidth: 180, maxHeight: 240)
                @unknown default:
                    EmptyView()
                        .frame(maxWidth: 180, maxHeight: 240)
                }
            }
            .frame(width: 180, height: 240)
            .clipped()
            
            VStack(alignment: .leading, spacing: 4) {
                Text(product.name)
                    .font(.system(size: 16))
                    .foregroundColor(.black)
                    .lineLimit(1)
                    .truncationMode(.tail)
                    .frame(width: 164)
                
                Text(product.formattedPrice)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.black)
            }
            .padding(.horizontal, 8)
            .frame(height: 50)
        }
        .frame(width: 180)
        .background(Color.white)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.gray.opacity(0.2), lineWidth: 0.5)
        )
        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
        .padding(.bottom, 8)
    }
} 
