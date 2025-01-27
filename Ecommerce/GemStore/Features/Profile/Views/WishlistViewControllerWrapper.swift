//
//  WishlistViewModel.swift
//  Ecommerce
//
//  Created by Imac on 23.01.25.
//

import SwiftUI

struct WishlistViewControllerWrapper: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> UIViewController {
        let viewModel = WishlistViewModel()
        let wishlistVC = WishlistViewController(viewModel: viewModel)
        wishlistVC.navigationItem.hidesBackButton = true
        wishlistVC.navigationItem.leftBarButtonItem = nil
        wishlistVC.navigationItem.backButtonTitle = ""
        wishlistVC.navigationItem.backBarButtonItem = nil
        wishlistVC.navigationItem.rightBarButtonItems = nil
        wishlistVC.navigationItem.leftBarButtonItems = nil
        return wishlistVC
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        uiViewController.navigationItem.hidesBackButton = true
        uiViewController.navigationItem.leftBarButtonItem = nil
        uiViewController.navigationItem.backButtonTitle = ""
        uiViewController.navigationItem.backBarButtonItem = nil
        uiViewController.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        uiViewController.navigationItem.rightBarButtonItems = nil
        uiViewController.navigationItem.leftBarButtonItems = nil
    }
} 
