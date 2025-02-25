//
//  SharedViews.swift
//  Ecommerce
//
//  Created by Imac on 22.01.25.
//

import SwiftUI

struct SharedErrorView: View {
    let error: Error
    let retryAction: () -> Void
    
    var body: some View {
        VStack {
            Text("Error: \(error.localizedDescription)")
                .multilineTextAlignment(.center)
                .padding()
            
            Button("Retry") {
                retryAction()
            }
        }
    }
}

struct SharedProductCard: View {
    let product: Product
    @State private var image: UIImage?
    
    var body: some View {
        VStack(alignment: .leading) {
            ZStack {
                if let image = image {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } else {
                    ProgressView()
                }
            }
            .frame(height: 200)
            .clipped()
            
            Text(product.name)
                .font(.subheadline)
                .foregroundColor(.black)
                .lineLimit(2)
                .padding(.horizontal, 8)
            
            Text(product.formattedPrice)
                .font(.headline)
                .foregroundColor(.black)
                .padding(.horizontal, 8)
                .padding(.bottom, 8)
        }
        .frame(width: UIScreen.main.bounds.width / 2 - 24)
        .background(Color.white)
        .cornerRadius(10)
        .shadow(radius: 2)
        .onAppear {
            loadImage()
        }
    }
    
    private func loadImage() {
        UnifiedCacheService.shared.loadImage(from: product.defaultImageUrl) { loadedImage in
            self.image = loadedImage
        }
    }
}

struct SharedProductDetailView: View {
    let product: Product
    let isFromHomePage: Bool
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        let viewModel = ProductDetailsViewModel(product: product)
        ProductDetailsViewControllerWrapper(viewModel: viewModel, 
                                         presentationMode: presentationMode,
                                         isFromHomePage: isFromHomePage)
            .navigationBarTitle("Product Details", displayMode: .inline)
            .navigationBarBackButtonHidden(false)
    }
}

struct ProductDetailsViewControllerWrapper: UIViewControllerRepresentable {
    let viewModel: ProductDetailsViewModel
    let presentationMode: Binding<PresentationMode>
    let isFromHomePage: Bool
    
    func makeUIViewController(context: Context) -> UIViewController {
        let viewController = ProductDetailsViewController(viewModel: viewModel)
        viewController.hideDefaultNavigationItems = false
        viewController.navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "chevron.left"),
            style: .plain,
            target: context.coordinator,
            action: #selector(Coordinator.dismiss)
        )
        return viewController
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject {
        let parent: ProductDetailsViewControllerWrapper
        
        init(_ parent: ProductDetailsViewControllerWrapper) {
            self.parent = parent
        }
        
        @objc func dismiss() {
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
}

