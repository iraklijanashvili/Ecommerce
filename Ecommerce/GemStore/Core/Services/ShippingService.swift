import Foundation
import FirebaseFirestore
import Combine

protocol ShippingServiceProtocol {
    func fetchCountries() async throws -> [String]
    func fetchShippingMethods() async throws -> [ShippingMethod]
}

class ShippingService: ShippingServiceProtocol {
    private let db = Firestore.firestore()
    
    func fetchCountries() async throws -> [String] {
        print("Fetching countries...")
        let document = try await db.collection("shipping").document("countries").getDocument()
        
        if let data = document.data(),
           let countries = data["countries"] as? [String] {
            print("Got countries: \(countries)")
            return countries
        }
        
        throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to fetch countries"])
    }
    
    func fetchShippingMethods() async throws -> [ShippingMethod] {
        print("Fetching shipping methods...")
        let document = try await db.collection("shipping").document("countries").getDocument()
        
        guard let data = document.data() else {
            throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No shipping methods found"])
        }
        
        print("Got shipping data: \(data)")
        var methods: [ShippingMethod] = []
        
        for methodId in ["free", "standard", "express"] {
            if let methodData = data[methodId] as? [String: Any] {
                print("Processing method: \(methodId), data: \(methodData)")
                
                let method = ShippingMethod(
                    id: methodData["id"] as? String ?? methodId,
                    title: methodData["title"] as? String ?? "",
                    description: methodData["description"] as? String ?? "",
                    price: methodData["price"] as? Double ?? 0.0,
                    deliveryTime: methodData["deliveryTime"] as? String ?? ""
                )
                methods.append(method)
                print("Added shipping method: \(method)")
            }
        }
        
        if methods.isEmpty {
            throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No shipping methods found"])
        }
        
        print("Total shipping methods loaded: \(methods.count)")
        return methods
    }
} 
