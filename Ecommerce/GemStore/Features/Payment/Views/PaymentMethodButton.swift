//
//  PaymentMethodButton.swift
//  Ecommerce
//
//  Created by Imac on 27.01.25.
//


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
