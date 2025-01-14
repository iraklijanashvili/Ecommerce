//
//  ImageLoader.swift
//  Ecommerce
//
//  Created by Imac on 13.01.25.
//



import Foundation
import UIKit

protocol ImageLoaderProtocol {
    func loadImage(from url: URL) async throws -> UIImage
}

actor ImageLoader: ImageLoaderProtocol {
    static let shared = ImageLoader()
    
    private let cache: ImageCacheProtocol
    private let session: URLSession
    
    private init(
        cache: ImageCacheProtocol = ImageCache.shared,
        session: URLSession = .shared
    ) {
        self.cache = cache
        self.session = session
    }
    
    func loadImage(from url: URL) async throws -> UIImage {
        if let cachedImage = cache.getImage(for: url) {
            return cachedImage
        }
        
        let (data, response) = try await session.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200,
              let image = UIImage(data: data) else {
            throw NetworkError.invalidResponse
        }
        
        cache.setImage(image, for: url)
        
        return image
    }
} 
