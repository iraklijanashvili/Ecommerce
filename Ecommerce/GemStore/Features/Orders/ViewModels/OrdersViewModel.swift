//
//  OrdersViewModel.swift
//  Ecommerce
//
//  Created by Imac on 29.01.25.
//

import Foundation

protocol OrdersViewModelDelegate: AnyObject {
    func ordersDidUpdate()
    func didEncounterError(_ error: Error)
}

class OrdersViewModel {
    private let ordersService: OrdersServiceProtocol
    weak var delegate: OrdersViewModelDelegate?
    
    private(set) var orders: [Order] = []
    private(set) var pendingOrders: [Order] = []
    private(set) var deliveredOrders: [Order] = []
    private(set) var cancelledOrders: [Order] = []
    
    init(ordersService: OrdersServiceProtocol, delegate: OrdersViewModelDelegate) {
        self.ordersService = ordersService
        self.delegate = delegate
    }
    
    func fetchOrders() {
        ordersService.fetchOrders { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let orders):
                self.orders = orders
                self.categorizeOrders()
                self.delegate?.ordersDidUpdate()
                
            case .failure(let error):
                self.delegate?.didEncounterError(error)
            }
        }
    }
    
    private func categorizeOrders() {
        pendingOrders = orders.filter { $0.status == .pending }
        deliveredOrders = orders.filter { $0.status == .delivered }
        cancelledOrders = orders.filter { $0.status == .cancelled }
    }
    
    func updateOrderStatus(_ order: Order, status: OrderStatus) {
        ordersService.updateOrderStatus(order, status: status) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success:
                self.fetchOrders()
                
            case .failure(let error):
                self.delegate?.didEncounterError(error)
            }
        }
    }
} 
