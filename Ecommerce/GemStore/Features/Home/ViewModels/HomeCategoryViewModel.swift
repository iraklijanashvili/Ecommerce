import Foundation
import FirebaseFirestore

class HomeCategoryViewModel: ObservableObject {
    @Published private(set) var categoryIcons: [String: String] = [:]
    private let db = Firestore.firestore()
    
    @MainActor
    func fetchCategoryIcons() async {
        do {
            let snapshot = try await db.collection("categoryIcons").getDocuments()
            var icons: [String: String] = [:]
            
            for document in snapshot.documents {
                if let iconUrl = document.data()["iconUrl"] as? String {
                    icons[document.documentID] = iconUrl
                }
            }
            
            self.categoryIcons = icons
        } catch {
            print("Error fetching category icons: \(error)")
        }
    }
} 