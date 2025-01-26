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
                VStack(spacing: 24) {
                    HStack(spacing: 16) {
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
                                .frame(width: 80, height: 80)
                                .clipShape(Circle())
                            } else {
                                Image(systemName: "person.circle.fill")
                                    .resizable()
                                    .frame(width: 80, height: 80)
                                    .foregroundColor(.gray)
                            }
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(profile.name ?? "No Name")
                                    .font(.title3)
                                    .bold()
                                
                                Text(profile.email ?? "No Email")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                            
                            Spacer()
                            
                            NavigationLink(destination: Text("Settings")) {
                                Image(systemName: "gearshape.fill")
                                    .font(.title2)
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                    .padding(.horizontal)
                    
                    Divider()
                        .padding(.horizontal)
                    
                    VStack(spacing: 0) {
                        ProfileMenuItem(icon: "mappin.and.ellipse", title: "Address", destination: Text("Address"))
                        
                        ProfileMenuItem(icon: "creditcard", title: "Payment Method", destination: PaymentView())
                        
                        NavigationLink {
                            WishlistViewControllerWrapper()
                                .navigationBarTitleDisplayMode(.inline)
                        } label: {
                            HStack {
                                Image(systemName: "heart")
                                    .font(.title3)
                                    .foregroundColor(.black)
                                
                                Text("My Wishlist")
                                    .foregroundColor(.black)
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.gray)
                            }
                            .padding()
                        }
                        Divider()
                            .padding(.horizontal)
                        
                        Button(action: {
                            viewModel.signOut()
                        }) {
                            HStack {
                                Image(systemName: "rectangle.portrait.and.arrow.right")
                                    .font(.title3)
                                    .foregroundColor(.red)
                                
                                Text("Log Out")
                                    .foregroundColor(.red)
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.gray)
                            }
                            .padding()
                        }
                    }
                    .background(Color.white)
                    .cornerRadius(12)
                    .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                    .padding(.horizontal)
                }
                .padding(.top, 20)
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

struct ProfileMenuItem<Destination: View>: View {
    let icon: String
    let title: String
    let destination: Destination
    
    var body: some View {
        NavigationLink(destination: destination) {
            HStack {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(.black)
                
                Text(title)
                    .foregroundColor(.black)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
            }
            .padding()
        }
        Divider()
            .padding(.horizontal)
    }
}
