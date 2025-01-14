//
//  NewCollectionView.swift
//  Ecommerce
//
//  Created by Imac on 13.01.25.
//


import SwiftUI

struct NewCollectionView: View {
    let imageURL: String
    
    var body: some View {
        GeometryReader { geometry in
            AsyncImageView(url: imageURL)
                .frame(width: geometry.size.width, height: 200)
                .cornerRadius(12)
        }
        .frame(height: 200)
    }
} 
