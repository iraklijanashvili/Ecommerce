//
//  ProductCard.swift
//  Ecommerce
//
//  Created by Imac on 13.01.25.
//


import SwiftUI

struct ProductCard: View {
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
            .frame(height: 150)
            .clipped()
            
            VStack(alignment: .leading, spacing: 4) {
                Text(product.name)
                    .font(.headline)
                
                Text(product.formattedPrice)
                    .font(.subheadline)
                    .bold()
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
        }
        .background(Color.white)
        .cornerRadius(10)
        .shadow(radius: 2)
    }
} 
