//
//  DatabaseService.swift
//  Ecommerce
//
//  Created by Imac on 30.01.25.
//


import Foundation
import FirebaseFirestore
import Combine

enum DatabaseError: Error {
    case notAuthenticated
    case documentNotFound
    case decodingError
    case encodingError
    case networkError
    case unknownError(String)
    
    var localizedDescription: String {
        switch self {
        case .notAuthenticated:
            return "User is not authenticated"
        case .documentNotFound:
            return "Document not found"
        case .decodingError:
            return "Failed to decode data"
        case .encodingError:
            return "Failed to encode data"
        case .networkError:
            return "Network error occurred"
        case .unknownError(let message):
            return message
        }
    }
}

protocol DatabaseService {
    func fetchDocument<T: Codable>(
        from collection: String,
        documentId: String
    ) async throws -> T
    
    func fetchDocuments<T: Codable>(
        from collection: String,
        whereField field: String,
        isEqualTo value: Any
    ) async throws -> [T]
    
    func saveDocument<T: Codable>(
        to collection: String,
        documentId: String?,
        data: T
    ) async throws -> String
    
    func deleteDocument(
        from collection: String,
        documentId: String
    ) async throws
    
    func observeCollection<T: Codable>(
        _ collection: String
    ) -> AnyPublisher<[T], Error>
    
    func performBatchOperation(_ operations: @escaping (WriteBatch) async throws -> Void) async throws
    
    func deleteCollection(_ collection: String) async throws
    
    func updateDocument(
        in collection: String,
        documentId: String,
        fields: [String: Any]
    ) async throws
}

class DatabaseServiceImpl: DatabaseService {
    private let db: Firestore
    private let cache: UnifiedCacheServiceProtocol
    
    init(
        db: Firestore = Firestore.firestore(),
        cache: UnifiedCacheServiceProtocol = UnifiedCacheService.shared
    ) {
        self.db = db
        self.cache = cache
    }
    
    private struct CachedItem<T: Codable>: Codable {
        let data: T
        let timestamp: Date
        let ttl: TimeInterval
        
        var isValid: Bool {
            Date().timeIntervalSince(timestamp) < ttl
        }
    }
    
    private func retry<T>(
        maxAttempts: Int = 3,
        initialDelay: TimeInterval = 1.0,
        operation: () async throws -> T
    ) async throws -> T {
        var attempts = 0
        var lastError: Error?
        var currentDelay = initialDelay
        
        repeat {
            do {
                return try await operation()
            } catch {
                attempts += 1
                lastError = error
                
                if attempts < maxAttempts {
                    try await Task.sleep(nanoseconds: UInt64(currentDelay * 1_000_000_000))
                    currentDelay *= 2
                }
            }
        } while attempts < maxAttempts
        
        throw lastError ?? DatabaseError.unknownError("Max retry attempts reached")
    }
    
    func fetchDocument<T: Codable>(
        from collection: String,
        documentId: String
    ) async throws -> T {
        return try await retry {
            let cacheKey = "\(collection)_\(documentId)"
            
            if let cachedItem: CachedItem<T> = cache.get(for: cacheKey),
               cachedItem.isValid {
                return cachedItem.data
            }
            
            let documentSnapshot = try await db.collection(collection).document(documentId).getDocument()
            
            guard let data = try? documentSnapshot.data(as: T.self) else {
                throw DatabaseError.decodingError
            }
            
            let cachedItem = CachedItem(data: data, timestamp: Date(), ttl: 300)
            cache.set(cachedItem, for: cacheKey)
            
            return data
        }
    }
    
    func fetchDocuments<T: Codable>(
        from collection: String,
        whereField field: String,
        isEqualTo value: Any
    ) async throws -> [T] {
        return try await retry {
            let cacheKey = "\(collection)_\(field)_\(value)"
            
            if let cachedItem: CachedItem<[T]> = cache.get(for: cacheKey),
               cachedItem.isValid {
                return cachedItem.data
            }
            
            let querySnapshot = try await db.collection(collection)
                .whereField(field, isEqualTo: value)
                .getDocuments()
            
            let results = try querySnapshot.documents.compactMap { document in
                try document.data(as: T.self)
            }
            
            let cachedItem = CachedItem(data: results, timestamp: Date(), ttl: 300)
            cache.set(cachedItem, for: cacheKey)
            
            return results
        }
    }
    
    func saveDocument<T: Codable>(
        to collection: String,
        documentId: String?,
        data: T
    ) async throws -> String {
        let documentRef: DocumentReference
        if let documentId = documentId {
            documentRef = db.collection(collection).document(documentId)
        } else {
            documentRef = db.collection(collection).document()
        }
        
        try documentRef.setData(from: data)
        
        let cacheKey = "\(collection)_\(documentRef.documentID)"
        let cachedItem = CachedItem(data: data, timestamp: Date(), ttl: 300)
        cache.set(cachedItem, for: cacheKey)
        
        return documentRef.documentID
    }
    
    func deleteDocument(
        from collection: String,
        documentId: String
    ) async throws {
        try await db.collection(collection).document(documentId).delete()
        
        let cacheKey = "\(collection)_\(documentId)"
        cache.remove(for: cacheKey)
    }
    
    func observeCollection<T: Codable>(_ collection: String) -> AnyPublisher<[T], Error> {
        let subject = PassthroughSubject<[T], Error>()
        
        db.collection(collection)
            .addSnapshotListener { [weak self] snapshot, error in
                if let error = error {
                    subject.send(completion: .failure(error))
                    return
                }
                
                guard let snapshot = snapshot else {
                    subject.send([])
                    return
                }
                
                do {
                    let items = try snapshot.documents.compactMap { document in
                        try document.data(as: T.self)
                    }
                    subject.send(items)
                } catch {
                    subject.send(completion: .failure(error))
                }
            }
        
        return subject.eraseToAnyPublisher()
    }
    
    func performBatchOperation(_ operations: @escaping (WriteBatch) async throws -> Void) async throws {
        let batch = db.batch()
        try await operations(batch)
        try await batch.commit()
    }
    
    func deleteCollection(_ collection: String) async throws {
        let snapshot = try await db.collection(collection).getDocuments()
        
        if snapshot.documents.isEmpty {
            return
        }
        
        try await performBatchOperation { batch in
            for document in snapshot.documents {
                batch.deleteDocument(document.reference)
            }
        }
    }
    
    func updateDocument(
        in collection: String,
        documentId: String,
        fields: [String: Any]
    ) async throws {
        let documentRef = db.collection(collection).document(documentId)
        
        let snapshot = try await documentRef.getDocument()
        guard snapshot.exists else {
            throw DatabaseError.documentNotFound
        }
        
        try await documentRef.updateData(fields)
        
        let cacheKey = "\(collection)_\(documentId)"
        cache.remove(for: cacheKey)
    }
} 
