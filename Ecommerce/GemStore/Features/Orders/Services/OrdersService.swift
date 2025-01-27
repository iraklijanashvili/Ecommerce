//
//  OrdersService.swift
//  Ecommerce
//
//  Created by Imac on 29.01.25.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth

protocol OrdersServiceProtocol {
    func fetchOrders(completion: @escaping (Result<[Order], Error>) -> Void)
    func updateOrderStatus(_ order: Order, status: OrderStatus, completion: @escaping (Result<Void, Error>) -> Void)
}

class OrdersService: OrdersServiceProtocol {
    private let db = Firestore.firestore()
    
    func fetchOrders(completion: @escaping (Result<[Order], Error>) -> Void) {
        guard let userId = Auth.auth().currentUser?.uid else {
            completion(.failure(NSError(domain: "OrdersService", code: 401, userInfo: [NSLocalizedDescriptionKey: "User not authenticated"])))
            return
        }
        
        db.collection("orders")
            .whereField("userId", isEqualTo: userId)
            .getDocuments { snapshot, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                let orders = snapshot?.documents.compactMap { document -> Order? in
                    let data = document.data()
                    
                    guard let id = data["id"] as? String,
                          let trackingNumber = data["trackingNumber"] as? String,
                          let quantity = data["quantity"] as? Int,
                          let subtotal = data["subtotal"] as? Double,
                          let statusRaw = data["status"] as? String,
                          let timestamp = data["date"] as? Timestamp else {
                        return nil
                    }
                    
                    let status = OrderStatus(rawValue: statusRaw) ?? .pending
                    let date = timestamp.dateValue()
                    
                    return Order(
                        id: id,
                        trackingNumber: trackingNumber,
                        quantity: quantity,
                        subtotal: subtotal,
                        status: status,
                        date: date
                    )
                } ?? []
                
                let sortedOrders = orders.sorted { $0.date > $1.date }
                completion(.success(sortedOrders))
                
                self.setupOrdersListener(userId: userId, completion: completion)
            }
    }
    
    private func setupOrdersListener(userId: String, completion: @escaping (Result<[Order], Error>) -> Void) {
        db.collection("orders")
            .whereField("userId", isEqualTo: userId)
            .addSnapshotListener { snapshot, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                let orders = snapshot?.documents.compactMap { document -> Order? in
                    let data = document.data()
                    
                    guard let id = data["id"] as? String,
                          let trackingNumber = data["trackingNumber"] as? String,
                          let quantity = data["quantity"] as? Int,
                          let subtotal = data["subtotal"] as? Double,
                          let statusRaw = data["status"] as? String,
                          let timestamp = data["date"] as? Timestamp else {
                        return nil
                    }
                    
                    let status = OrderStatus(rawValue: statusRaw) ?? .pending
                    let date = timestamp.dateValue()
                    
                    return Order(
                        id: id,
                        trackingNumber: trackingNumber,
                        quantity: quantity,
                        subtotal: subtotal,
                        status: status,
                        date: date
                    )
                } ?? []
                
                let sortedOrders = orders.sorted { $0.date > $1.date }
                completion(.success(sortedOrders))
            }
    }
    
    func updateOrderStatus(_ order: Order, status: OrderStatus, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let userId = Auth.auth().currentUser?.uid else {
            completion(.failure(NSError(domain: "OrdersService", code: 401, userInfo: [NSLocalizedDescriptionKey: "User not authenticated"])))
            return
        }
        
        db.collection("orders").document(order.id).updateData([
            "status": status.rawValue,
            "userId": userId
        ]) { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }
} 
