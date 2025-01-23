//
//  CartService.swift
//  Ecommerce
//
//  Created by Imac on 24.01.25.
//

import Foundation
import Combine
import FirebaseFirestore
import FirebaseAuth

typealias CartService = CartServiceProtocol

protocol CartServiceProtocol {
    var items: [CartItem] { get }
    var itemsPublisher: AnyPublisher<[CartItem], Never> { get }
    var totalPrice: Double { get }
    var totalPricePublisher: AnyPublisher<Double, Never> { get }
    
    func addToCart(product: Product, quantity: Int, size: String, color: ProductColor)
    func removeFromCart(itemId: String)
    func updateQuantity(itemId: String, quantity: Int)
    func clearCart()
}

class CartServiceImpl: CartServiceProtocol {
    static let shared = CartServiceImpl()
    
    private let db = Firestore.firestore()
    @Published private(set) var items: [CartItem] = []
    @Published private(set) var totalPrice: Double = 0
    
    var itemsPublisher: AnyPublisher<[CartItem], Never> {
        $items.eraseToAnyPublisher()
    }
    
    var totalPricePublisher: AnyPublisher<Double, Never> {
        $totalPrice.eraseToAnyPublisher()
    }
    
    private init() {
        startObservingCart()
        
        $items
            .map { items in
                items.reduce(0) { $0 + $1.totalPrice }
            }
            .assign(to: &$totalPrice)
    }
    
    private func startObservingCart() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        db.collection("userCarts")
            .document(userId)
            .collection("items")
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self,
                      let snapshot = snapshot else { return }
                
                self.items = snapshot.documents.compactMap { document in
                    try? document.data(as: CartItem.self)
                }
            }
    }
    
    func addToCart(product: Product, quantity: Int, size: String, color: ProductColor) {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        let itemId = "\(product.id)_\(size)_\(color.rawValue)"
        let cartItem = CartItem(
            id: itemId,
            product: product,
            quantity: quantity,
            selectedSize: size,
            selectedColor: color
        )
        
        do {
            try db.collection("userCarts")
                .document(userId)
                .collection("items")
                .document(itemId)
                .setData(from: cartItem)
        } catch {
            print("Error adding to cart: \(error)")
        }
    }
    
    func removeFromCart(itemId: String) {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        db.collection("userCarts")
            .document(userId)
            .collection("items")
            .document(itemId)
            .delete()
    }
    
    func updateQuantity(itemId: String, quantity: Int) {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        if quantity <= 0 {
            removeFromCart(itemId: itemId)
            return
        }
        
        db.collection("userCarts")
            .document(userId)
            .collection("items")
            .document(itemId)
            .updateData(["quantity": quantity])
    }
    
    func clearCart() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        let batch = db.batch()
        db.collection("userCarts")
            .document(userId)
            .collection("items")
            .getDocuments { snapshot, error in
                guard let snapshot = snapshot else { return }
                
                snapshot.documents.forEach { document in
                    batch.deleteDocument(document.reference)
                }
                
                batch.commit()
            }
    }
} 
