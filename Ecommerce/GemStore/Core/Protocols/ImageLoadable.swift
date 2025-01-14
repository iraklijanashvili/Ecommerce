//
//  ImageLoadable.swift
//  Ecommerce
//
//  Created by Imac on 13.01.25.
//

import SwiftUI

protocol ImageLoadable {
    func loadImage(from url: String) async throws -> Image
}

struct DefaultImageLoader: ImageLoadable {
    func loadImage(from url: String) async throws -> Image {
        guard let url = URL(string: url) else {
            throw URLError(.badURL)
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        guard let uiImage = UIImage(data: data) else {
            throw URLError(.cannotDecodeContentData)
        }
        
        return Image(uiImage: uiImage)
    }
} 
