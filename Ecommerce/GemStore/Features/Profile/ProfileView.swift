//
//  ProfileView.swift
//  Ecommerce
//
//  Created by Imac on 13.01.25.
//

import SwiftUI
import FirebaseAuth

struct ProfileView: View {
    @EnvironmentObject private var authManager: AuthenticationStateManager
    @StateObject private var viewModel = ProfileViewModel()
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    if let profile = viewModel.userProfile {
                        if let photoURL = profile.photoURL {
                            AsyncImage(url: photoURL) { image in
                                image
                                    .resizable()
                                    .scaledToFill()
                            } placeholder: {
                                Image(systemName: "person.circle.fill")
                                    .resizable()
                                    .foregroundColor(.gray)
                            }
                            .frame(width: 100, height: 100)
                            .clipShape(Circle())
                        } else {
                            Image(systemName: "person.circle.fill")
                                .resizable()
                                .frame(width: 100, height: 100)
                                .foregroundColor(.gray)
                        }
                        
                        Text(profile.name ?? "No Name")
                            .font(.title2)
                            .bold()
                        
                        Text(profile.email ?? "No Email")
                            .foregroundColor(.gray)
                    }
                    
                    Divider()
                        .padding(.vertical)
                    
                    Button(action: {
                        viewModel.signOut()
                    }) {
                        Text("Sign Out")
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.red)
                            .cornerRadius(10)
                    }
                    .padding(.horizontal)
                }
                .padding(.top, 40)
            }
            .navigationTitle("Profile")
            .alert("Error", isPresented: Binding(
                get: { viewModel.error != nil },
                set: { if !$0 { viewModel.error = nil } }
            )) {
                Button("OK", role: .cancel) {}
            } message: {
                if let error = viewModel.error {
                    Text(error.localizedDescription)
                }
            }
        }
    }
} 
