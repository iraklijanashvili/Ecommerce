import SwiftUI

struct PaymentMethodButton: View {
    let isSelected: Bool
    let icon: String
    let title: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.title2)
                Text(title)
                    .font(.subheadline)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(isSelected ? Color.black : Color.white)
            .foregroundColor(isSelected ? .white : .black)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
            )
        }
    }
}

struct PaymentCardView: View {
    let card: PaymentCard
    let logoUrl: String?
    let isSelected: Bool
    let onSelect: () -> Void
    
    var body: some View {
        Button(action: onSelect) {
            VStack(alignment: .leading, spacing: 20) {
                HStack {
                    if let logoUrl = logoUrl {
                        CachedAsyncImage(url: logoUrl, width: 60)
                    }
                    Spacer()
                }
                
                Text(card.cardNumber)
                    .font(.system(.title3, design: .monospaced))
                    .foregroundColor(.white)
                
                HStack {
                    VStack(alignment: .leading) {
                        Text("CARDHOLDER NAME")
                            .font(.caption2)
                            .foregroundColor(.white.opacity(0.7))
                        Text(card.cardholderName)
                            .font(.caption)
                            .foregroundColor(.white)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .leading) {
                        Text("VALID THRU")
                            .font(.caption2)
                            .foregroundColor(.white.opacity(0.7))
                        Text(card.expiryDate)
                            .font(.caption)
                            .foregroundColor(.white)
                    }
                }
            }
            .padding()
            .frame(width: 300, height: 180)
            .background(
                LinearGradient(
                    colors: [.blue, .blue.opacity(0.8)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.white, lineWidth: isSelected ? 2 : 0)
            )
            .cornerRadius(16)
        }
    }
} 