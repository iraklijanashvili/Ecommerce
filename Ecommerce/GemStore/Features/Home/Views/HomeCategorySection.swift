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
    @State private var selectedCategory: Category?
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 16) {
                ForEach(categories) { category in
                    CategoryCard(category: category)
                        .onTapGesture {
                            if let encoded = try? JSONEncoder().encode(category) {
                                UserDefaults.standard.set(encoded, forKey: "selectedCategory")
                            }
                            selectedTab = 1 
                        }
                }
            }
            .padding(.horizontal)
        }
    }
}

private struct CategoryCard: View {
    let category: Category
    
    var body: some View {
        VStack {
            AsyncImage(url: URL(string: category.imageUrl)) { phase in
                switch phase {
                case .empty:
                    ProgressView()
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
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
            .frame(width: 100, height: 100)
            .clipShape(Circle())
            
            Text(category.name)
                .font(.caption)
                .foregroundColor(.black)
                .lineLimit(2)
                .multilineTextAlignment(.center)
        }
        .frame(width: 100)
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
