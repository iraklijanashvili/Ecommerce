//
//  WishlistViewModel.swift
//  Ecommerce
//
//  Created by Imac on 23.01.25.
//

import SwiftUI

struct WishlistViewControllerWrapper: UIViewControllerRepresentable {
    @Environment(\.dismiss) var dismiss
    
    func makeUIViewController(context: Context) -> UIViewController {
        let viewModel = WishlistViewModel()
        let wishlistVC = WishlistViewController(viewModel: viewModel)
        
        let backButton = UIBarButtonItem(
            image: UIImage(systemName: "chevron.left"),
            style: .plain,
            target: context.coordinator,
            action: #selector(Coordinator.backButtonTapped)
        )
        backButton.tintColor = .black
        wishlistVC.navigationItem.leftBarButtonItem = backButton
        
        return wishlistVC
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(dismiss: dismiss)
    }
    
    class Coordinator: NSObject {
        let dismiss: DismissAction
        
        init(dismiss: DismissAction) {
            self.dismiss = dismiss
        }
        
        @objc func backButtonTapped() {
            dismiss()
        }
    }
} 
