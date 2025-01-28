//
//  ProductCardView.swift
//  Ecommerce
//
//  Created by Imac on 22.01.25.
//

import SwiftUI

struct ProductCardView: View {
    let product: Product
    
    var body: some View {
        VStack(alignment: .leading) {
            if let imageUrl = product.imageUrl {
                AsyncImage(url: URL(string: imageUrl)) { phase in
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
                .frame(height: 120)
                .clipped()
            } else {
                Color.gray
                    .overlay(
                        Image(systemName: "photo")
                            .foregroundColor(.white)
                    )
                    .frame(height: 120)
                    .clipped()
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(product.name)
                    .font(.headline)
                    .lineLimit(2)
                
                Text(product.formattedPrice)
                    .font(.subheadline)
                    .foregroundColor(.blue)
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
        }
        .background(Color.white)
        .cornerRadius(12)
        .shadow(radius: 2)
    }
} 
