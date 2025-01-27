//
//  ImageCacheService.swift
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
    private var loadingTasks: [String: Task<UIImage?, Error>] = [:]
    
    private init() {
        cache.countLimit = 100
        cache.totalCostLimit = 50 * 1024 * 1024 // 50 MB
    }
    
    func object(forKey key: String) -> UIImage? {
        cache.object(forKey: key as NSString)
    }
    
    func setObject(_ image: UIImage, forKey key: String) {
        let cost = Int(image.size.width * image.size.height * 4)
        cache.setObject(image, forKey: key as NSString, cost: cost)
    }
    
    func removeObject(forKey key: String) {
        cache.removeObject(forKey: key as NSString)
    }
    
    func clearCache() {
        cache.removeAllObjects()
    }
    
    func loadImage(from urlString: String) async throws -> UIImage? {
        if let cachedImage = object(forKey: urlString) {
            return cachedImage
        }
        
        if let existingTask = loadingTasks[urlString] {
            let image = try await existingTask.value
            return image
        }
        
        let task = Task<UIImage?, Error> {
            guard let url = URL(string: urlString) else { return nil }
            
            do {
                let (data, _) = try await URLSession.shared.data(from: url)
                if let image = UIImage(data: data) {
                    setObject(image, forKey: urlString)
                    return image
                }
                return nil
            } catch {
                throw error
            }
        }
        
        loadingTasks[urlString] = task
        
        do {
            let image = try await task.value
            loadingTasks[urlString] = nil
            return image
        } catch {
            loadingTasks[urlString] = nil
            throw error
        }
    }
}

class ImageCacheService {
    static let shared = ImageCacheService()
    private let cache: ImageCache
    
    private init() {
        self.cache = .shared
    }
    
    @MainActor
    func loadImage(from urlString: String) async -> UIImage? {
        do {
            return try await cache.loadImage(from: urlString)
        } catch {
            print("Error loading image: \(error)")
            return nil
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
        CachedImageView(urlString: urlString)
    }
}

struct CachedImageView: View {
    let urlString: String
    @State private var image: UIImage?
    @State private var isLoading = true
    
    var body: some View {
        Group {
            if let image = image {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } else {
                if isLoading {
                    ProgressView()
                } else {
                    Image(systemName: "photo")
                        .foregroundColor(.gray)
                }
            }
        }
        .onAppear {
            loadImageIfNeeded()
        }
    }
    
    private func loadImageIfNeeded() {
        guard image == nil else { return }
        
        Task {
            if let cachedImage = await ImageCache.shared.object(forKey: urlString) {
                await MainActor.run {
                    self.image = cachedImage
                    self.isLoading = false
                }
                return
            }
            
            do {
                if let loadedImage = try await ImageCache.shared.loadImage(from: urlString) {
                    await MainActor.run {
                        self.image = loadedImage
                    }
                }
            } catch {
                print("Error loading image: \(error)")
            }
            
            await MainActor.run {
                self.isLoading = false
            }
        }
    }
}
