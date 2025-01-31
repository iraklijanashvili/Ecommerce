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
            UnifiedCachedImageView(urlString: product.defaultImageUrl)
                .frame(height: 150)
                .clipped()
            
            VStack(alignment: .leading, spacing: 4) {
                Text(product.name)
                    .font(.headline)
                    .foregroundColor(.black)
                    .lineLimit(1)
                    .truncationMode(.tail)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Text(product.formattedPrice)
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundColor(.black)
            }
            .frame(height: 50)
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
        }
        .background(Color.white)
        .cornerRadius(10)
        .shadow(radius: 2)
    }
}
