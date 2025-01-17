////
////  TopCollectionView.swift
////  Ecommerce
////
////  Created by Imac on 16.01.25.
////
//
//
//import SwiftUI
//
//struct TopCollectionView: View {
//    let topImageURL: String
//    
//    var body: some View {
//        GeometryReader { geometry in
//            VStack(spacing: 16) {
//                AsyncImage(url: URL(string: topImageURL)) { phase in
//                    switch phase {
//                    case .empty:
//                        ProgressView()
//                    case .success(let image):
//                        image
//                            .resizable()
//                            .aspectRatio(contentMode: .fit)
//                    case .failure:
//                        Color.gray
//                            .overlay(
//                                Image(systemName: "photo")
//                                    .foregroundColor(.white)
//                            )
//                    @unknown default:
//                        EmptyView()
//                    }
//                }
//                .frame(width: geometry.size.width, height: 200)
//                .clipped()
//                .cornerRadius(12)
//            }
//        }
//        .frame(height: 200)
//    }
//} 
