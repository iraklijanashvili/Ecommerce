//
//  CustomTextField.swift
//  Ecommerce
//
//  Created by Imac on 22.01.25.
//


import SwiftUI

struct CustomTextField: View {
    let title: String
    @Binding var text: String
    var isEnabled: Bool = true
    var rightIcon: String? = nil
    var isRequired: Bool = true
    var error: String? = nil
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(title)
                    .font(.caption)
                    .foregroundColor(.gray)
                if isRequired {
                    Text("*")
                        .foregroundColor(.red)
                        .font(.caption)
                }
            }
            
            HStack {
                TextField("", text: $text)
                    .disabled(!isEnabled)
                    .textFieldStyle(PlainTextFieldStyle())
                
                if let icon = rightIcon {
                    Image(systemName: icon)
                        .foregroundColor(.gray)
                }
            }
            .padding(.vertical, 8)
            
            Rectangle()
                .frame(height: 1)
                .foregroundColor(error != nil ? .red : .gray.opacity(0.3))
            
            if let error = error {
                Text(error)
                    .font(.caption)
                    .foregroundColor(.red)
            }
        }
    }
} 
