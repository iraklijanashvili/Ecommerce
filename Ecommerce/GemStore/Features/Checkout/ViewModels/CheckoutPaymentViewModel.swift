import Foundation
import Combine

@MainActor
class CheckoutPaymentViewModel: PaymentViewModel {
    @Published var selectedPaymentMethod: PaymentMethod = .creditCard
    @Published var selectedCard: PaymentCard?
    @Published var cards: [PaymentCard] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var showAddCard = false
    
    var subtotal: Double = 0
    var shipping: String = ""
    
    var total: Double {
        subtotal
    }
    
    enum PaymentMethod {
        case cash
        case creditCard
    }
    
    override init(paymentService: PaymentServiceProtocol = PaymentServiceImpl.shared) {
        super.init(paymentService: paymentService)
        Task {
            await loadCards()
        }
    }
    
    func loadCards() async {
        isLoading = true
        do {
            cards = try await paymentService.fetchCards()
            if let firstCard = cards.first {
                selectedCard = firstCard
            }
            isLoading = false
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
        }
    }
    
    func placeOrder() async -> Bool {
        guard selectedPaymentMethod == .creditCard else {
            return true // Cash payment is always valid
        }
        
        guard let selectedCard = selectedCard else {
            errorMessage = "Please select a payment method"
            return false
        }
        
        // Here you would implement the actual order placement logic
        return true
    }
} 