//
//  PaymentCardView.swift
//  Ecommerce
//
//  Created by Imac on 27.01.25.
//


import SwiftUI

struct PaymentCardView: View {
    let card: PaymentCard
    let logoUrl: String?
    let isSelected: Bool
    let onSelect: () -> Void
    var onDelete: (() -> Void)?
    
    var body: some View {
        Button(action: onSelect) {
            VStack(alignment: .leading, spacing: 20) {
                HStack {
                    if let logoUrl = logoUrl {
                        UnifiedCachedImageView(urlString: logoUrl)
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 60, height: 40)
                            .clipped()
                    }
                    
                    if isSelected {
                        Spacer()
                        HStack(spacing: 4) {
                            Text("Selected")
                                .font(.caption)
                                .foregroundColor(.white)
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.white)
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.green.opacity(0.8))
                        .cornerRadius(12)
                    }
                    
                    Spacer()
                    
                    if let onDelete = onDelete {
                        Button(action: onDelete) {
                            Image(systemName: "trash.circle.fill")
                                .foregroundColor(.white)
                                .font(.title2)
                        }
                    }
                }
                
                Text(card.maskedNumber)
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
                    colors: isSelected ? [.blue, .blue.opacity(0.6)] : [.blue.opacity(0.8), .blue.opacity(0.6)],
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
