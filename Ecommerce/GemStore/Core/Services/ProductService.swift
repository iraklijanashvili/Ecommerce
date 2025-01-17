import Foundation

protocol ProductService {
    func fetchProducts() async throws -> [Product]
    func getProductsForCategory(_ categoryId: String) async throws -> [Product]
    func getFeaturedProducts(from products: [Product]) -> [Product]
    func getRecommendedProducts(from products: [Product]) -> [Product]
}

class ProductServiceImpl: ProductService {
    private let repository: FirestoreRepository
    
    init(repository: FirestoreRepository = FirestoreRepositoryImpl()) {
        self.repository = repository
    }
    
    func fetchProducts() async throws -> [Product] {
        return try await repository.getProducts()
    }
    
    func getProductsForCategory(_ categoryId: String) async throws -> [Product] {
        return try await repository.getProductsForCategory(categoryId)
    }
    
    func getFeaturedProducts(from products: [Product]) -> [Product] {
        return products.filter { $0.isFeatured }
    }
    
    func getRecommendedProducts(from products: [Product]) -> [Product] {
        return products.filter { $0.isRecommended }
    }
} 