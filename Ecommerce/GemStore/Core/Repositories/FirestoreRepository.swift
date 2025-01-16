//
//  FirestoreRepository.swift
//  Ecommerce
//
//  Created by Imac on 16.01.25.
//



import Foundation
import FirebaseFirestore

protocol FirestoreRepository {
    func getBanners() async throws -> [Banner]
    func getProducts() async throws -> [Product]
}

class FirestoreRepositoryImpl: FirestoreRepository {
    private let db = Firestore.firestore()
    
    func getBanners() async throws -> [Banner] {
        let bannerDocuments = ["Main Banner", "New Collection", "Top Collection", "Summer Collection"]
        var banners: [Banner] = []
        
        for document in bannerDocuments {
            do {
                let snapshot = try await db.collection("banners").document(document).getDocument()
                
                if let data = snapshot.data() {
                    if let imageUrl = data["image_url"] as? String {
                        let type: Banner.BannerType
                        switch document {
                        case "Main Banner":
                            type = .main
                        case "New Collection":
                            type = .newCollection
                        case "Top Collection":
                            type = .topCollection
                        case "Summer Collection":
                            type = .summerCollection
                        default:
                            continue
                        }
                        
                        let banner = Banner(
                            id: data["id"] as? String ?? "",
                            title: data["title"] as? String ?? type.displayTitle,
                            description: data["description"] as? String ?? "",
                            imageUrl: imageUrl,
                            linkId: data["link_id"] as? String ?? "",
                            linkType: type
                        )
                        banners.append(banner)
                    }
                }
            } catch {
                throw error
            }
        }
        
        return banners
    }
    
    func getProducts() async throws -> [Product] {
        let snapshot = try await db.collection("products").getDocuments()
        
        return try snapshot.documents.compactMap { document in
            var data = document.data()
            if data["id"] == nil {
                data["id"] = document.documentID
            }
            return try Firestore.Decoder().decode(Product.self, from: data)
        }
    }
} 
