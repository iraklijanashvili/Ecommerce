//
//  OrderCompletedView.swift
//  Ecommerce
//
//  Created by Imac on 27.01.25.
//


import SwiftUI
import FirebaseStorage
import FirebaseFirestore

struct OrderCompletedView: View {
    @StateObject private var viewModel: OrderCompletedViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var imageUrl: String?
    
    init(navigationDelegate: OrderCompletionNavigationDelegate) {
        _viewModel = StateObject(wrappedValue: OrderCompletedViewModel(navigationDelegate: navigationDelegate))
    }
    
    var body: some View {
        VStack(spacing: 0) {
            navigationBar
            
            ScrollView {
                VStack(spacing: 24) {
                    progressIndicator
                        .padding(.horizontal)
                    
                    completionContent
                        .padding(.horizontal)
                    
                    continueButton
                        .padding(.horizontal)
                }
                .padding(.vertical)
            }
        }
        .background(Color(.systemGroupedBackground))
        .navigationBarHidden(true)
        .onAppear {
            fetchOrderCompletedImage()
        }
    }
    
    private func fetchOrderCompletedImage() {
        let db = Firestore.firestore()
        let docRef = db.collection("assets").document("orderComplete")
        
        docRef.getDocument { document, error in
            if let error = error {
                print("Error getting document: \(error)")
                return
            }
            
            if let document = document, document.exists {
                if let url = document.data()?["imageUrl"] as? String {
                    self.imageUrl = url
                }
            }
        }
    }
    
    private var navigationBar: some View {
        HStack {
            Button(action: { dismiss() }) {
                Image(systemName: "chevron.left")
                    .foregroundColor(.primary)
                    .imageScale(.large)
            }
            
            Spacer()
            
            Text("Check out")
                .font(.headline)
            
            Spacer()
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(Color(.systemBackground))
    }
    
    private var progressIndicator: some View {
        HStack(spacing: 0) {
            StepIndicator(icon: "mappin.circle.fill", isActive: true)
            Line()
                .foregroundColor(.gray.opacity(0.3))
            StepIndicator(icon: "creditcard", isActive: true)
            Line()
                .foregroundColor(.gray.opacity(0.3))
            StepIndicator(icon: "checkmark.circle", isActive: true)
        }
    }
    
    private var completionContent: some View {
        VStack(spacing: 32) {
            Text("Order Completed")
                .font(.title)
                .bold()
            
            if let imageUrl = imageUrl {
                AsyncImage(url: URL(string: imageUrl)) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 120, height: 120)
                } placeholder: {
                    ProgressView()
                        .frame(width: 120, height: 120)
                }
            } else {
                Image(systemName: "checkmark.circle.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 120, height: 120)
                    .foregroundColor(.black)
            }
            
            VStack(spacing: 8) {
                Text("Thank you for your purchase.")
                    .font(.headline)
                
                Text("You can view your order in 'My Orders' section.")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(.vertical, 40)
    }
    
    private var continueButton: some View {
        Button(action: viewModel.continueToHome) {
            Text("Continue shopping")
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(Color.black)
                .cornerRadius(25)
        }
        .padding(.top, 8)
    }
} 
