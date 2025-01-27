//
//  CheckoutComponents.swift
//  Ecommerce
//
//  Created by Imac on 27.01.25.
//


import SwiftUI

struct StepIndicator: View {
    let icon: String
    let isActive: Bool
    
    var body: some View {
        Image(systemName: icon)
            .imageScale(.large)
            .foregroundColor(isActive ? .blue : .gray)
            .frame(width: 44, height: 44)
            .background(
                Circle()
                    .fill(isActive ? .blue.opacity(0.1) : .gray.opacity(0.1))
            )
    }
}

struct Line: View {
    var body: some View {
        Rectangle()
            .frame(height: 1)
    }
} 
