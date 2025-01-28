//
//  MainTabView.swift
//  Ecommerce
//
//  Created by Imac on 13.01.25.
//


import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView(selectedTab: $selectedTab)
                .tabItem {
                    Image(systemName: selectedTab == 0 ? "house.fill" : "house")
                    Text("Home")
                }
                .tag(0)
            
            DiscoverViewControllerRepresentable()
                .tabItem {
                    Image(systemName: selectedTab == 1 ? "magnifyingglass.circle.fill" : "magnifyingglass.circle")
                    Text("Discover")
                }
                .tag(1)
            
            CartView()
                .tabItem {
                    Image(systemName: selectedTab == 2 ? "cart.fill" : "cart")
                    Text("Cart")
                }
                .tag(2)
            
            ProfileView()
                .tabItem {
                    Image(systemName: selectedTab == 3 ? "person.fill" : "person")
                    Text("Profile")
                }
                .tag(3)
        }
    }
}

struct DiscoverViewControllerRepresentable: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> DiscoverViewController {
        return DiscoverViewController()
    }
    
    func updateUIViewController(_ uiViewController: DiscoverViewController, context: Context) {
    }
}
