//
//  BannerView.swift
//  Ecommerce
//
//  Created by Imac on 13.01.25.
//

import SwiftUI

struct BannerView: View {
    let imageURL: String
    let title: BannerTitle
    
    struct BannerTitle {
        let mainText: String
        let subText: String
        let yearText: String
        
        static let autumn = BannerTitle(
            mainText: "Autumn",
            subText: "Collection",
            yearText: "2024"
        )
    }
    
    init(
        imageURL: String,
        title: BannerTitle = .autumn
    ) {
        self.imageURL = imageURL
        self.title = title
    }
    
    var body: some View {
        GeometryReader { geometry in
            AsyncImageView(url: imageURL)
                .frame(width: geometry.size.width, height: 200)
                .overlay(
                    BannerTitleOverlay(title: title),
                    alignment: .leading
                )
        }
        .frame(height: 200)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

private struct BannerTitleOverlay: View {
    let title: BannerView.BannerTitle
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title.mainText)
            Text(title.subText)
            Text(title.yearText)
        }
        .font(.title)
        .foregroundColor(.white)
        .padding()
        .shadow(radius: 2)
    }
}
