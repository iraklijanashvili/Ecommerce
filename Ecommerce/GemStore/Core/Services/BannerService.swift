import Foundation

protocol BannerService {
    func fetchBanners() async throws -> [Banner]
    func getBannersByType(_ type: String) -> [Banner]
}

class BannerServiceImpl: BannerService {
    private let repository: FirestoreRepository
    
    init(repository: FirestoreRepository = FirestoreRepositoryImpl()) {
        self.repository = repository
    }
    
    func fetchBanners() async throws -> [Banner] {
        return try await repository.getBanners()
    }
    
    func getBannersByType(_ type: String) -> [Banner] {
        // Implementation will be added when needed
        return []
    }
} 