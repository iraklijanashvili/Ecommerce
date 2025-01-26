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
        ImageCacheService.shared.loadImage(from: product.imageUrl) { loadedImage in
            self.image = loadedImage
        }
    }
}

struct SharedProductDetailView: View {
    let product: Product
    let isFromHomePage: Bool
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            let viewModel = ProductDetailsViewModel(product: product)
            ProductDetailsViewControllerWrapper(viewModel: viewModel, 
                                                 presentationMode: presentationMode,
                                                 isFromHomePage: isFromHomePage)
                .navigationBarItems(leading: Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.black)
                })
                .navigationBarTitle("Product Details", displayMode: .inline)
        }
    }
}

struct ProductDetailsViewControllerWrapper: UIViewControllerRepresentable {
    let viewModel: ProductDetailsViewModel
    let presentationMode: Binding<PresentationMode>
    let isFromHomePage: Bool
    
    func makeUIViewController(context: Context) -> UIViewController {
        let viewController = ProductDetailsViewController(viewModel: viewModel)
        if isFromHomePage {
            viewController.hideDefaultNavigationItems = true
        }
        return viewController
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
    }
}

struct CachedAsyncImage: View {
    let url: String
    let width: CGFloat
    @State private var image: UIImage?
    
    var body: some View {
        Group {
            if let image = image {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            } else {
                ProgressView()
            }
        }
        .frame(width: width)
        .task {
            image = await ImageCacheService.shared.loadImage(from: url)
        }
    }
} 
