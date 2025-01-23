import SwiftUI

struct WishlistViewControllerWrapper: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> UIViewController {
        let viewModel = WishlistViewModel()
        let wishlistVC = WishlistViewController(viewModel: viewModel)
        return wishlistVC
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
} 