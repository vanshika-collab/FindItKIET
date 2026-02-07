//
//  AppRouter.swift
//  FindItKIET
//
//  Handles navigation between authenticated and unauthenticated states
//

import SwiftUI

struct AppRouter: View {
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        Group {
            if appState.isAuthenticated {
                // Main app with tab bar
                MainTabView()
            } else {
                // Authentication screens
                LoginView()
            }
        }
        .animation(.easeInOut, value: appState.isAuthenticated)
    }
}

// MARK: - Main Tab View
struct MainTabView: View {
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        TabView {
            ItemListView()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
            
            ReportItemView()
                .tabItem {
                    Label("Report", systemImage: "plus.circle.fill")
                }
            
            MyClaimsView()
                .tabItem {
                    Label("My Claims", systemImage: "checkmark.circle.fill")
                }
            
            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person.fill")
                }
            
            // Show admin tab only for admin users
            if appState.currentUser?.role == .admin {
                AdminClaimReviewView()
                    .tabItem {
                        Label("Admin", systemImage: "shield.fill")
                    }
            }
        }
        .tint(AppColors.primaryBlue)
    }
}
