import Foundation
import Combine

@MainActor
class HomeViewModel: ObservableObject {
    @Published var banners: [Banner] = []
    @Published var categories: [Category] = []
    @Published var featuredProducts: [Product] = []
    @Published var recommendedProducts: [Product] = []
    @Published var isLoading = false
    @Published var error: Error?
    
    private let bannerService: BannerService
    private let categoryService: CategoryService
    private let productService: ProductService
    
    init(
        bannerService: BannerService = BannerServiceImpl(),
        categoryService: CategoryService = CategoryServiceImpl(),
        productService: ProductService = ProductServiceImpl()
    ) {
        self.bannerService = bannerService
        self.categoryService = categoryService
        self.productService = productService
    }
    
    func loadData() async {
        isLoading = true
        error = nil
        
        do {
            async let bannersTask = bannerService.fetchBanners()
            async let categoriesTask = categoryService.fetchCategories()
            async let featuredTask = productService.getProductsForCategory("featured")
            async let recommendedTask = productService.getProductsForCategory("recommended")
            
            let (banners, categories, featured, recommended) = try await (
                bannersTask,
                categoriesTask,
                featuredTask,
                recommendedTask
            )
            
            self.banners = banners
            self.categories = categories
            self.featuredProducts = featured
            self.recommendedProducts = recommended
        } catch {
            self.error = error
        }
        
        isLoading = false
    }
    
    // Banner filtering
    var mainBanners: [Banner] {
        banners.filter { $0.type == "main" }
    }
    
    var newCollectionBanner: Banner? {
        banners.first { $0.type == "new_collection" }
    }
    
    var topCollectionBanner: Banner? {
        banners.first { $0.type == "top_collection" }
    }
    
    var summerCollectionBanner: Banner? {
        banners.first { $0.type == "summer_collection" }
    }
} 