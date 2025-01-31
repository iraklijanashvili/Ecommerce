import Foundation
import FirebaseFirestore

class FirestoreCategoryIconRepository: CategoryIconRepository {
    private let firestore: Firestore
    
    init(firestore: Firestore = Firestore.firestore()) {
        self.firestore = firestore
    }
    
    func fetchCategoryIcons() async throws -> [String: String] {
        do {
            let categoryIds = ["accessories", "clothing", "collection", "shoes"]
            var icons: [String: String] = [:]
            
            for categoryId in categoryIds {
                let snapshot = try await firestore.collection("categoryIcons").document(categoryId).getDocument()
                
                if let data = snapshot.data(), let iconUrl = data["iconUrl"] as? String {
                    icons[categoryId] = iconUrl
                }
            }
            
            print("📱 All category icons loaded: \(icons)")
            return icons
        } catch {
            print("❌ Error fetching category icons: \(error)")
            throw error
        }
    }
} 
