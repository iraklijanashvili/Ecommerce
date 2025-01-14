//
//  NetworkService.swift
//  Ecommerce
//
//  Created by Imac on 13.01.25.
//

import Foundation
import FirebaseStorage

protocol NetworkServiceProtocol {
    func fetchImage(path: String) async throws -> URL
    func fetchProducts() async throws -> [Product]
}

enum NetworkError: Error {
    case invalidURL
    case invalidResponse
    case decodingError
    case serverError(String)
}

final class NetworkService: NetworkServiceProtocol {
    private let storage: Storage
    
    init(storage: Storage = Storage.storage()) {
        self.storage = storage
    }
    
    func fetchImage(path: String) async throws -> URL {
        try await withCheckedThrowingContinuation { continuation in
            storage.reference().child(path).downloadURL { url, error in
                if let error = error {
                    continuation.resume(throwing: NetworkError.serverError(error.localizedDescription))
                    return
                }
                
                guard let url = url else {
                    continuation.resume(throwing: NetworkError.invalidURL)
                    return
                }
                
                continuation.resume(returning: url)
            }
        }
    }
    
    func fetchProducts() async throws -> [Product] {
        return [
            Product(
                name: "Turtleneck Sweater",
                price: 39.99,
                imageURL: try await fetchImage(path: "images/SportWear.png").absoluteString,
                section: .featured
            ),
            Product(
                name: "Long Sleeve Dress",
                price: 45.00,
                imageURL: try await fetchImage(path: "images/dress1.png").absoluteString,
                section: .featured
            ),
            Product(
                name: "Designer Dress",
                price: 65.00,
                imageURL: try await fetchImage(path: "images/dress.png").absoluteString,
                section: .featured
            ),
            Product(
                name: "Designer Dress",
                price: 65.00,
                imageURL: try await fetchImage(path: "images/dress.png").absoluteString,
                section: .featured
            ),
            
            Product(
                name: "White Fashion Hoodie",
                price: 29.00,
                imageURL: try await fetchImage(path: "images/WhiteFashion.png").absoluteString,
                section: .recommended
            ),
            Product(
                name: "Cotton T-Shirt",
                price: 30.00,
                imageURL: try await fetchImage(path: "images/CottonShirt.png").absoluteString,
                section: .recommended
            )
        ]
    }
}
