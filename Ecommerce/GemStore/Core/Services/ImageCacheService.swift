//
//  ImageCache.swift
//  Ecommerce
//
//  Created by Imac on 21.01.25.
//

import Foundation
import UIKit
import SwiftUI

actor ImageCache {
    static let shared = ImageCache()
    private var cache = NSCache<NSString, UIImage>()
    
    private init() {
        cache.countLimit = 100
    }
    
    func object(forKey key: String) -> UIImage? {
        cache.object(forKey: key as NSString)
    }
    
    func setObject(_ image: UIImage, forKey key: String) {
        cache.setObject(image, forKey: key as NSString)
    }
    
    func removeObject(forKey key: String) {
        cache.removeObject(forKey: key as NSString)
    }
    
    func clearCache() {
        cache.removeAllObjects()
    }
}

class ImageCacheService {
    static let shared = ImageCacheService()
    private let cache: ImageCache
    private let queue = DispatchQueue(label: "com.gemstore.imagecache")
    
    private init() {
        self.cache = .shared
    }
    
    @MainActor
    func loadImage(from urlString: String) async -> UIImage? {
        if let cachedImage = await cache.object(forKey: urlString) {
            return cachedImage
        }
        
        guard let url = URL(string: urlString) else { return nil }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            if let image = UIImage(data: data) {
                await cache.setObject(image, forKey: urlString)
                return image
            }
        } catch {
            print("Error loading image with URLSession: \(error)")
        }
        
        return await withCheckedContinuation { continuation in
            let imageView = AsyncImage(url: url) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                case .failure:
                    Image(systemName: "photo")
                        .foregroundColor(.gray)
                case .empty:
                    ProgressView()
                @unknown default:
                    EmptyView()
                }
            }
            
            let hostingController = UIHostingController(rootView: imageView)
            hostingController.view.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
            
            if let snapshot = hostingController.view.snapshotImage() {
                Task {
                    await self.cache.setObject(snapshot, forKey: urlString)
                }
                continuation.resume(returning: snapshot)
            } else {
                continuation.resume(returning: nil)
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                continuation.resume(returning: nil)
            }
        }
    }
    
    func loadImage(from urlString: String, completion: @escaping (UIImage?) -> Void) {
        Task {
            let image = await loadImage(from: urlString)
            DispatchQueue.main.async {
                completion(image)
            }
        }
    }
    
    func clearCache() {
        Task {
            await cache.clearCache()
        }
    }
}

extension Image {
    static func cached(_ urlString: String) -> some View {
        AsyncImage(url: URL(string: urlString)) { phase in
            switch phase {
            case .empty:
                ProgressView()
            case .success(let image):
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            case .failure:
                Image(systemName: "photo")
                    .foregroundColor(.gray)
            @unknown default:
                EmptyView()
            }
        }
    }
}

extension UIView {
    func snapshotImage() -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(bounds.size, false, UIScreen.main.scale)
        drawHierarchy(in: bounds, afterScreenUpdates: true)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
} 
