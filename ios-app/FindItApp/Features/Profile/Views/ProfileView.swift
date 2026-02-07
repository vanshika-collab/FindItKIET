//
//  ProfileView.swift
//  FindItKIET
//
//  User profile screen
//

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    if let user = appState.currentUser {
                        HStack {
                            Image(systemName: "person.circle.fill")
                                .font(.system(size: 50))
                                .foregroundColor(AppColors.primaryBlue)
                            
                            VStack(alignment: .leading) {
                                Text(user.name)
                                    .font(.headline)
                                Text(user.email)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                StatusBadge(status: .found) // Placeholder
                            }
                        }
                        .padding(.vertical, 8)
                    }
                }
                
                Section("App Info") {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }
                }
                
                Section {
                    Button(action: {
                        appState.logout()
                    }) {
                        HStack {
                            Spacer()
                            Text("Logout")
                                .foregroundColor(AppColors.error)
                            Spacer()
                        }
                    }
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Profile")
        }
    }
}
