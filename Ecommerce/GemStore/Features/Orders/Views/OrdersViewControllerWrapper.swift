//
//  OrdersViewControllerWrapper.swift
//  Ecommerce
//
//  Created by Imac on 29.01.25.
//

import SwiftUI

struct OrdersViewControllerWrapper: UIViewControllerRepresentable {
    @Environment(\.presentationMode) var presentationMode
    
    func makeUIViewController(context: Context) -> UIViewController {
        let service = OrdersService()
        let ordersVC = OrdersViewController(viewModel: OrdersViewModel(ordersService: service, delegate: context.coordinator))
        context.coordinator.ordersViewController = ordersVC
        context.coordinator.presentationMode = presentationMode
        return ordersVC
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        context.coordinator.presentationMode = presentationMode
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    class Coordinator: OrdersViewModelDelegate {
        weak var ordersViewController: OrdersViewController?
        var presentationMode: Binding<PresentationMode>?
        
        func ordersDidUpdate() {
            DispatchQueue.main.async { [weak self] in
                self?.ordersViewController?.ordersDidUpdate()
            }
        }
        
        func didEncounterError(_ error: Error) {
            DispatchQueue.main.async { [weak self] in
                self?.ordersViewController?.didEncounterError(error)
            }
        }
        
        func dismiss() {
            presentationMode?.wrappedValue.dismiss()
        }
    }
}
