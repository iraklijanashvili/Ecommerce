//
//  BannerView.swift
//  Ecommerce
//
//  Created by Imac on 13.01.25.
//


import SwiftUI

struct BannerView: View {
    let banner: Banner
    
    var body: some View {
        NavigationLink(destination: destinationView) {
            GeometryReader { geometry in
                AsyncImage(url: URL(string: banner.imageUrl)) { phase in
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
                .frame(width: geometry.size.width, height: 200)
                .overlay(
                    BannerTitleOverlay(banner: banner),
                    alignment: .leading
                )
            }
            .frame(height: 200)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }
    
    @ViewBuilder
    private var destinationView: some View {
        if let bannerType = banner.bannerType {
            switch bannerType {
            case .newCollection:
                CollectionProductsView(
                    collectionType: bannerType.rawValue,
                    title: bannerType.displayTitle,
                    isFromHomePage: true
                )
            case .topCollection:
                CollectionProductsView(
                    collectionType: bannerType.rawValue,
                    title: bannerType.displayTitle,
                    isFromHomePage: true
                )
            case .summerCollection:
                CollectionProductsView(
                    collectionType: bannerType.rawValue,
                    title: bannerType.displayTitle,
                    isFromHomePage: true
                )
            case .main:
                EmptyView()
            }
        } else {
            EmptyView()
        }
    }
}

private struct BannerTitleOverlay: View {
    let banner: Banner
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(banner.title)
                .font(.title)
            Text(banner.description)
                .font(.subheadline)
        }
        .foregroundColor(.white)
        .padding()
        .shadow(radius: 2)
    }
} 
