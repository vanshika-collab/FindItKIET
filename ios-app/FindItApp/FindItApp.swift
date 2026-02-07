//
//  FindItApp.swift
//  FindItKIET
//
//  Production-ready campus lost-and-found iOS app
//

import SwiftUI

@main
struct FindItApp: App {
    @StateObject private var appState = AppState()
    
    var body: some Scene {
        WindowGroup {
            AppRouter()
                .environmentObject(appState)
        }
    }
}
