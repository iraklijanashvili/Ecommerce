import Foundation

@MainActor
class DiscoverViewModel: ObservableObject {
    @Published var categories: [Category] = []
    @Published var selectedCategory: Category?
    @Published var products: [Product] = []
    @Published var isLoading = false
    @Published var error: Error?
    
    private let categoryService: CategoryService
    private let productService: ProductService
    
    init(
        categoryService: CategoryService = CategoryServiceImpl(),
        productService: ProductService = ProductServiceImpl()
    ) {
        self.categoryService = categoryService
        self.productService = productService
    }
    
    func loadData() async {
        isLoading = true
        error = nil
        
        do {
            categories = try await categoryService.fetchCategories()
            if let firstCategory = categories.first {
                await selectCategory(firstCategory)
            }
        } catch {
            self.error = error
        }
        
        isLoading = false
    }
    
    func selectCategory(_ category: Category) async {
        selectedCategory = category
        isLoading = true
        error = nil
        
        do {
            products = try await productService.getProductsForCategory(category.id)
        } catch {
            self.error = error
        }
        
        isLoading = false
    }
} 