//
//  GemStoreApp.swift
//  Ecommerce
//
//  Created by Imac on 13.01.25.
//

import SwiftUI
import FirebaseCore
import FirebaseAuth
import GoogleSignIn

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        
        if !UserDefaults.standard.bool(forKey: "hasRunBefore") {
            try? Auth.auth().signOut()
            GIDSignIn.sharedInstance.signOut()
            
            UserDefaults.standard.set(true, forKey: "hasRunBefore")
        }
        
        return true
    }
}

class AuthenticationStateManager: ObservableObject {
    @Published var isAuthenticated = false
    private var authStateHandler: AuthStateDidChangeListenerHandle?
    
    init() {
        if !UserDefaults.standard.bool(forKey: "hasRunBefore") {
            isAuthenticated = false
        }
        
        authStateHandler = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            self?.isAuthenticated = user != nil
        }
    }
    
    deinit {
        if let handler = authStateHandler {
            Auth.auth().removeStateDidChangeListener(handler)
        }
    }
    
    func signOut() {
        do {
            try Auth.auth().signOut()
            GIDSignIn.sharedInstance.signOut()
            UserDefaults.standard.set(false, forKey: "hasRunBefore")
        } catch {
            print("Error signing out: \(error.localizedDescription)")
        }
    }
}

@main
struct GemStoreApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject private var store = AppStore.shared
    @StateObject private var authManager = AuthenticationStateManager()
    
    var body: some Scene {
        WindowGroup {
            NavigationView {
                Group {
                    if authManager.isAuthenticated {
                        MainTabView()
                            .environmentObject(store)
                            .environmentObject(authManager)
                            .task {
                                await store.initialize()
                            }
                    } else {
                        SignUpViewControllerRepresentable()
                    }
                }
            }
            .navigationViewStyle(.stack)
        }
    }
}
