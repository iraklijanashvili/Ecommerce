import Foundation

protocol CategoryService {
    func fetchCategories() async throws -> [Category]
    func getCategoryById(_ id: String) -> Category?
}

class CategoryServiceImpl: CategoryService {
    private let repository: FirestoreRepository
    private var cachedCategories: [Category] = []
    
    init(repository: FirestoreRepository = FirestoreRepositoryImpl()) {
        self.repository = repository
    }
    
    func fetchCategories() async throws -> [Category] {
        let categories = try await repository.getCategories()
        cachedCategories = categories
        return categories
    }
    
    func getCategoryById(_ id: String) -> Category? {
        return cachedCategories.first { $0.id == id }
    }
} 