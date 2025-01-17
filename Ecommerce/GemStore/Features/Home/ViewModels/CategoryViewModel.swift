import Foundation

@MainActor
class CategoryViewModel: ObservableObject {
    @Published var categories: [Category] = []
    @Published var isLoading = false
    @Published var error: Error?
    
    private let categoryService: CategoryService
    
    init(categoryService: CategoryService = CategoryServiceImpl()) {
        self.categoryService = categoryService
    }
    
    func loadCategories() async {
        isLoading = true
        error = nil
        
        do {
            categories = try await categoryService.fetchCategories()
        } catch {
            self.error = error
        }
        
        isLoading = false
    }
    
    func getCategory(by id: String) -> Category? {
        return categoryService.getCategoryById(id)
    }
} 