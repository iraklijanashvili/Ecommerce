//
//  GemStoreApp.swift
//  Ecommerce
//
//  Created by Imac on 13.01.25.
//

import SwiftUI
import FirebaseCore

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        return true
    }
}

@main
struct GemStoreApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject private var store = AppStore.shared
    
    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environmentObject(store)
                .task {
                    await store.initialize()
                }
        }
    }
}
