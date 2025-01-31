//
//  UnifiedCacheService.swift
//  Ecommerce
//
//  Created by Imac on 30.01.25.
//

import Foundation
import UIKit
import SwiftUI

protocol UnifiedCacheServiceProtocol {
    func get<T: Codable>(for key: String) -> T?
    func set<T: Codable>(_ value: T, for key: String)
    func remove(for key: String)
    func clear()
    
    func loadImage(from urlString: String) async -> UIImage?
    func loadImage(from urlString: String, completion: @escaping (UIImage?) -> Void)
    func clearImageCache()
    func clearCache(for urlString: String)
}

final class UnifiedCacheService: UnifiedCacheServiceProtocol {
    static let shared = UnifiedCacheService()
    
    private let dataCache = NSCache<NSString, NSData>()
    private let imageCache = NSCache<NSString, UIImage>()
    private var loadingTasks: [String: Task<UIImage?, Error>] = [:]
    
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    
    private init() {
        dataCache.countLimit = 100
        dataCache.totalCostLimit = 50 * 1024 * 1024
        
        imageCache.countLimit = 100
        imageCache.totalCostLimit = 50 * 1024 * 1024
    }
    
    
    func get<T: Codable>(for key: String) -> T? {
        guard let data = dataCache.object(forKey: key as NSString) as Data? else {
            return nil
        }
        return try? decoder.decode(T.self, from: data)
    }
    
    func set<T: Codable>(_ value: T, for key: String) {
        guard let data = try? encoder.encode(value) else {
            return
        }
        dataCache.setObject(data as NSData, forKey: key as NSString)
    }
    
    func remove(for key: String) {
        dataCache.removeObject(forKey: key as NSString)
    }
    
    func clear() {
        dataCache.removeAllObjects()
    }
    
    
    @MainActor
    func loadImage(from urlString: String) async -> UIImage? {
        if let cachedImage = imageCache.object(forKey: urlString as NSString) {
            return cachedImage
        }
        
        if let existingTask = loadingTasks[urlString] {
            return try? await existingTask.value
        }
        
        let task = Task<UIImage?, Error> { [weak self] in
            guard let url = URL(string: urlString) else { return nil }
            
            do {
                let (data, response) = try await URLSession.shared.data(from: url)
                
                guard !Task.isCancelled,
                      let self = self,
                      let response = response as? HTTPURLResponse,
                      response.statusCode == 200,
                      let image = UIImage(data: data) else {
                    return nil
                }
                
                if self.loadingTasks[urlString]?.isCancelled == false {
                    let cost = Int(image.size.width * image.size.height * 4)
                    self.imageCache.setObject(image, forKey: urlString as NSString, cost: cost)
                    return image
                }
                return nil
            } catch {
                return nil
            }
        }
        
        loadingTasks[urlString] = task
        
        let image = try? await task.value
        loadingTasks[urlString] = nil
        return image
    }
    
    func loadImage(from urlString: String, completion: @escaping (UIImage?) -> Void) {
        Task {
            let image = await loadImage(from: urlString)
            DispatchQueue.main.async {
                completion(image)
            }
        }
    }
    
    func clearImageCache() {
        imageCache.removeAllObjects()
    }
    
    func clearCache(for urlString: String) {
        imageCache.removeObject(forKey: urlString as NSString)
        if let task = loadingTasks[urlString] {
            task.cancel()
            loadingTasks[urlString] = nil
        }
    }
}

extension Image {
    static func cached(_ urlString: String) -> some View {
        UnifiedCachedImageView(urlString: urlString)
    }
}

struct UnifiedCachedImageView: View {
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
            if let loadedImage = await UnifiedCacheService.shared.loadImage(from: urlString) {
                await MainActor.run {
                    self.image = loadedImage
                    self.isLoading = false
                }
            } else {
                await MainActor.run {
                    self.isLoading = false
                }
            }
        }
    }
} 
