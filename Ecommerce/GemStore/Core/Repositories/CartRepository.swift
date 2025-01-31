import Foundation
import FirebaseAuth
import FirebaseFirestore
import Combine

protocol CartRepository {
    func observeCartItems() -> AnyPublisher<[CartItem], Never>
    func addItem(_ item: CartItem) async throws
    func removeItem(withId id: String) async throws
    func updateItemQuantity(id: String, quantity: Int) async throws
    func clearCart() async throws
}

class CartRepositoryImpl: CartRepository {
    private let databaseService: DatabaseService
    private let cartItemsSubject = CurrentValueSubject<[CartItem], Never>([])
    private var cancellables = Set<AnyCancellable>()
    
    init(databaseService: DatabaseService = DatabaseServiceImpl()) {
        self.databaseService = databaseService
        setupCartObserver()
    }
    
    private func setupCartObserver() {
        guard let userId = Auth.auth().currentUser?.uid else {
            cartItemsSubject.send([])
            return
        }
        
        let path = "userCarts/\(userId)/items"
        databaseService.observeCollection(path)
            .catch { error -> AnyPublisher<[CartItem], Never> in
                print("Error observing cart items: \(error)")
                return Just([]).eraseToAnyPublisher()
            }
            .sink { [weak self] items in
                self?.cartItemsSubject.send(items)
            }
            .store(in: &cancellables)
    }
    
    func observeCartItems() -> AnyPublisher<[CartItem], Never> {
        return cartItemsSubject.eraseToAnyPublisher()
    }
    
    func addItem(_ item: CartItem) async throws {
        guard let userId = Auth.auth().currentUser?.uid else {
            throw DatabaseError.notAuthenticated
        }
        
        let path = "userCarts/\(userId)/items"
        _ = try await databaseService.saveDocument(
            to: path,
            documentId: item.id,
            data: item
        )
    }
    
    func removeItem(withId id: String) async throws {
        guard let userId = Auth.auth().currentUser?.uid else {
            throw DatabaseError.notAuthenticated
        }
        
        let path = "userCarts/\(userId)/items"
        try await databaseService.deleteDocument(
            from: path,
            documentId: id
        )
    }
    
    func updateItemQuantity(id: String, quantity: Int) async throws {
        guard let userId = Auth.auth().currentUser?.uid else {
            throw DatabaseError.notAuthenticated
        }
        
        if quantity <= 0 {
            try await removeItem(withId: id)
            return
        }
        
        let path = "userCarts/\(userId)/items"
        try await databaseService.updateDocument(
            in: path,
            documentId: id,
            fields: ["quantity": quantity]
        )
    }
    
    func clearCart() async throws {
        guard let userId = Auth.auth().currentUser?.uid else {
            throw DatabaseError.notAuthenticated
        }
        
        let path = "userCarts/\(userId)/items"
        try await databaseService.deleteCollection(path)
    }
} 