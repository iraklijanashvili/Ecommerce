import Foundation

struct Product: Identifiable {
    let id = UUID()
    let name: String
    let price: Double
    let imageUrl: String
}
