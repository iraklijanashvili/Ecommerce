import Foundation

@MainActor
class ProductViewModel: ObservableObject {
    @Published var products: [Product] = []
    @Published var isLoading = false
    @Published var error: Error?
    
    private let categoryId: String
    private let productService: ProductService
    
    init(
        categoryId: String,
        productService: ProductService = ProductServiceImpl()
    ) {
        self.categoryId = categoryId
        self.productService = productService
    }
    
    func loadProducts() async {
        isLoading = true
        error = nil
        
        do {
            products = try await productService.getProductsForCategory(categoryId)
        } catch {
            self.error = error
        }
        
        isLoading = false
    }
} 