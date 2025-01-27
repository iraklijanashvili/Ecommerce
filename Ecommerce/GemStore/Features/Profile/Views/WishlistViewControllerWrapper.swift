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
        return wishlistVC
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
} 
