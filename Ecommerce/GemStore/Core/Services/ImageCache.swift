//
//  ImageCache.swift
//  Ecommerce
//
//  Created by Imac on 13.01.25.
//

import Foundation
import UIKit

protocol ImageCacheProtocol {
    func setImage(_ image: UIImage, for url: URL)
    func getImage(for url: URL) -> UIImage?
    func removeImage(for url: URL)
    func clearCache()
}

final class ImageCache: ImageCacheProtocol {
    static let shared = ImageCache()
    
    private let cache = NSCache<NSURL, UIImage>()
    private let lock = NSLock()
    
    private init() {
        cache.totalCostLimit = 1024 * 1024 * 100
        cache.countLimit = 100 
        
        NotificationCenter.default.addObserver(
            forName: UIApplication.didReceiveMemoryWarningNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.clearCache()
        }
    }
    
    func setImage(_ image: UIImage, for url: URL) {
        lock.lock()
        defer { lock.unlock() }
        cache.setObject(image, forKey: url as NSURL)
    }
    
    func getImage(for url: URL) -> UIImage? {
        lock.lock()
        defer { lock.unlock() }
        return cache.object(forKey: url as NSURL)
    }
    
    func removeImage(for url: URL) {
        lock.lock()
        defer { lock.unlock() }
        cache.removeObject(forKey: url as NSURL)
    }
    
    func clearCache() {
        lock.lock()
        defer { lock.unlock() }
        cache.removeAllObjects()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
} 
