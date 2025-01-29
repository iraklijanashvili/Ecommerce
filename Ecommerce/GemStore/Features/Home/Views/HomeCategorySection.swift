//
//  HomeCategorySection.swift
//  Ecommerce
//
//  Created by Imac on 13.01.25.
//

import SwiftUI

struct HomeCategorySection: View {
    let categories: [Category]
    @Binding var selectedTab: Int
    @StateObject private var categoryManager = CategorySelectionManager.shared
    @StateObject private var viewModel = HomeCategoryViewModel()
    
    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        LazyVGrid(columns: columns, spacing: 16) {
            ForEach(categories) { category in
                CategoryCard(category: category, iconUrl: viewModel.categoryIcons[category.id])
                    .onTapGesture {
                        categoryManager.selectCategory(category)
                        selectedTab = 1
                    }
            }
        }
        .padding(.horizontal)
        .onAppear {
            Task {
                await viewModel.fetchCategoryIcons()
            }
        }
    }
}

private struct CategoryCard: View {
    let category: Category
    let iconUrl: String?
    
    var body: some View {
        VStack(spacing: 4) {
            AsyncImage(url: URL(string: iconUrl ?? category.imageUrl)) { phase in
                switch phase {
                case .empty:
                    ProgressView()
                        .frame(width: 45, height: 45)
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .scaleEffect(0.7)
                case .failure:
                    Color.gray
                        .overlay(
                            Image(systemName: "photo")
                                .foregroundColor(.white)
                        )
                @unknown default:
                    EmptyView()
                }
            }
            .frame(width: 45, height: 45)
            .clipShape(Circle())
            .overlay(
                Circle()
                    .stroke(Color.black.opacity(0.2), lineWidth: 0.5)
            )
            
            Text(category.name)
                .font(.caption2)
                .foregroundColor(.black)
                .lineLimit(1)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
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
