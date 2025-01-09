import Foundation
import FirebaseStorage

class ProductViewModel: ObservableObject {
    @Published var products: [Product] = []
    private let storage = Storage.storage()
    
    init() {
        fetchProducts()
    }
    
    func fetchProducts() {
        var demoProducts = [
            Product(name: "Festive Dress", price: 65.0, imageUrl: "images/5.png"),
            Product(name: "Elegant Dress", price: 75.0, imageUrl: "images/5.png"),
            Product(name: "Sportwear Set", price: 80.0, imageUrl: "images/5.png")
        ]
        
        let group = DispatchGroup()
        
        for (index, product) in demoProducts.enumerated() {
            group.enter()
            getImageURL(for: product.imageUrl) { url in
                if let url = url {
                    demoProducts[index] = Product(name: product.name, price: product.price, imageUrl: url.absoluteString)
                }
                group.leave()
            }
        }
        
        group.notify(queue: .main) {
            self.products = demoProducts
        }
    }
    func getImageURL(for path: String, completion: @escaping (URL?) -> Void) {
        let storageRef = storage.reference().child(path)
        storageRef.downloadURL { url, error in
            DispatchQueue.main.async {
                completion(url)
            }
        }
    }
}
