//
//  HomeCategorySection.swift
//  Ecommerce
//
//  Created by Imac on 13.01.25.
//

import SwiftUI

struct HomeCategorySection: View {
    @StateObject private var viewModel: HomeCategorySectionViewModel
    @Binding var selectedTab: Int
    
    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    init(categories: [Category], selectedTab: Binding<Int>) {
        let iconRepository = FirestoreCategoryIconRepository()
        let selectionHandler = CategorySelectionManager.shared
        _selectedTab = selectedTab
        _viewModel = StateObject(wrappedValue: HomeCategorySectionViewModel(
            categories: categories,
            iconRepository: iconRepository,
            selectionHandler: selectionHandler
        ))
    }
    
    var body: some View {
        VStack {
            if viewModel.isLoading && viewModel.categoryIcons.isEmpty {
                ProgressView()
            } else if let error = viewModel.error {
                ErrorView(error: error) {
                    Task {
                        await viewModel.loadCategoryIcons()
                    }
                }
            } else {
                categoriesGrid
            }
        }
        .onAppear {
            if viewModel.categoryIcons.isEmpty {
                Task {
                    await viewModel.loadCategoryIcons()
                }
            }
        }
    }
    
    private var categoriesGrid: some View {
        LazyVGrid(columns: columns, spacing: 16) {
            ForEach(viewModel.categories) { category in
                CategoryCard(
                    category: category,
                    iconUrl: viewModel.getIconUrl(for: category.id)
                )
                .onTapGesture {
                    viewModel.handleCategorySelection(category)
                    selectedTab = 1
                }
            }
        }
        .padding(.horizontal)
    }
}

private struct CategoryCard: View {
    let category: Category
    let iconUrl: String?
    
    var body: some View {
        VStack(spacing: 4) {
            categoryIcon
            
            Text(category.name)
                .font(.caption2)
                .foregroundColor(.black)
                .lineLimit(1)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
    }
    
    private var categoryIcon: some View {
        Group {
            if let iconUrl = iconUrl {
                UnifiedCachedImageView(urlString: iconUrl)
                    .frame(width: 45, height: 45)
                    .scaleEffect(0.7)
            } else {
                fallbackImage
            }
        }
        .clipShape(Circle())
        .overlay(
            Circle()
                .stroke(Color.black.opacity(0.2), lineWidth: 0.5)
        )
    }
    
    private var fallbackImage: some View {
        Group {
            if let url = URL(string: category.imageUrl) {
                UnifiedCachedImageView(urlString: category.imageUrl)
                    .frame(width: 45, height: 45)
                    .scaleEffect(0.7)
            } else {
                Color.gray
                    .overlay(
                        Image(systemName: "photo")
                            .foregroundColor(.white)
                    )
                    .frame(width: 45, height: 45)
                    .scaleEffect(0.7)
            }
        }
    }
}

private struct ErrorView: View {
    let error: Error
    let retryAction: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            Text("Error loading categories")
                .font(.headline)
            
            Text(error.localizedDescription)
                .font(.subheadline)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
            
            Button("Retry") {
                retryAction()
            }
            .buttonStyle(.bordered)
        }
        .padding()
    }
}

struct DiscoverViewControllerWrapper: UIViewControllerRepresentable {
    let selectedCategory: Category
    @Environment(\.presentationMode) var presentationMode
    
    func makeUIViewController(context: Context) -> UIViewController {
        let viewModel = DiscoverViewModel()
        let viewController = DiscoverViewController(viewModel: viewModel)
        
        let navigationController = UINavigationController(rootViewController: viewController)
        
        viewController.selectCategory(selectedCategory)
        
        let closeButton = UIBarButtonItem(
            image: UIImage(systemName: "xmark"),
            style: .plain,
            target: context.coordinator,
            action: #selector(Coordinator.dismiss)
        )
        viewController.navigationItem.leftBarButtonItem = closeButton
        
        return navigationController
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject {
        let parent: DiscoverViewControllerWrapper
        
        init(_ parent: DiscoverViewControllerWrapper) {
            self.parent = parent
        }
        
        @objc func dismiss() {
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}

struct CategoryProductsView: View {
    let categoryId: String
    let title: String
    @StateObject private var viewModel = DiscoverViewModel()
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 16) {
                ForEach(viewModel.products) { product in
                    ProductCard(product: product)
                }
            }
            .padding()
        }
        .navigationTitle(title)
        .onAppear {
            viewModel.fetchProducts(for: categoryId)
        }
    }
} 
