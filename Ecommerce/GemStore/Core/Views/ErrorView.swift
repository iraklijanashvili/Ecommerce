//
//  ErrorView.swift
//  Ecommerce
//
//  Created by Imac on 22.01.25.
//

import SwiftUI

struct ErrorView: View {
    let error: Error
    let retryAction: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 50))
                .foregroundColor(.red)
            
            Text("Error")
                .font(.title)
            
            Text(error.localizedDescription)
                .multilineTextAlignment(.center)
                .foregroundColor(.gray)
            
            Button(action: retryAction) {
                Text("Try Again")
                    .foregroundColor(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(Color.blue)
                    .cornerRadius(8)
            }
        }
        .padding()
    }
} 
