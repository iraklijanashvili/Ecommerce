//
//  TopCollectionView.swift
//  Ecommerce
//
//  Created by Imac on 13.01.25.
//


import SwiftUI

struct TopCollectionView: View {
    let topImageURL: String
    let bottomImageURL: String
    
    var body: some View {
        VStack(spacing: 15) {
            GeometryReader { geometry in
                AsyncImageView(url: topImageURL)
                    .frame(width: geometry.size.width, height: 200)
                    .aspectRatio(contentMode: .fit)
                    .cornerRadius(12)
            }
            .frame(height: 200)
            
            GeometryReader { geometry in
                AsyncImageView(url: bottomImageURL)
                    .frame(width: geometry.size.width, height: 200)
                    .aspectRatio(contentMode: .fit)
                    .cornerRadius(12)
            }
            .frame(height: 200)
        }
        .padding(.horizontal, 8)
    }
} 
