//
//  ProfileView.swift
//  FindItKIET
//
//  User profile screen
//

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var appState: AppState
    @StateObject private var viewModel = ProfileViewModel()
    
    var body: some View {
        NavigationView {
            ZStack {
                AppColors.background.ignoresSafeArea()
                
                List {
                    if let user = appState.currentUser {
                        Section {
                            profileHeader(user: user)
                                .listRowInsets(EdgeInsets())
                                .listRowBackground(Color.clear)
                        }
                    }
                    
                    // Certificate Section
                    if let user = appState.currentUser {
                        Section {
                            // Certificate Actions
                            if user.role == .admin {
                                // Admin: Send Certificates
                                Button(action: {
                                    Task { await viewModel.sendCertificatesToTopReporters() }
                                }) {
                                    HStack {
                                        if viewModel.isLoading {
                                            ProgressView()
                                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                                .padding(.trailing, 8)
                                            Text("Sending...")
                                                .fontWeight(.semibold)
                                        } else {
                                            Image(systemName: "paperplane.fill")
                                            Text("Send Certificates to Top 3")
                                                .fontWeight(.semibold)
                                        }
                                        Spacer()
                                    }
                                    .foregroundColor(.white)
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background(
                                        LinearGradient(
                                            colors: [Color.orange, Color.red],
                                            startPoint: .leading, endPoint: .trailing
                                        )
                                    )
                                    .cornerRadius(12)
                                    .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 3)
                                }
                                .disabled(viewModel.isLoading)
                                .listRowInsets(EdgeInsets())
                                .listRowBackground(Color.clear)
                                .padding(.vertical, 4)
                            } else {
                                // User: Download Certificate
                                Button(action: {
                                    if viewModel.hasCertificate {
                                        if let url = URL(string: "http://localhost:8000/api/download-certificate?email=\(user.email)") {
                                            UIApplication.shared.open(url)
                                        }
                                    } else {
                                        viewModel.alertMessage = "You have not received any certificate yet"
                                        viewModel.showAlert = true
                                    }
                                }) {
                                    HStack {
                                        Image(systemName: "arrow.down.doc.fill")
                                        Text("Download Certificate")
                                            .fontWeight(.semibold)
                                        Spacer()
                                    }
                                    .foregroundColor(.white)
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background(viewModel.hasCertificate ? AppColors.success : Color.gray)
                                    .cornerRadius(12)
                                    .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 3)
                                }
                                .listRowInsets(EdgeInsets())
                                .listRowBackground(Color.clear)
                                .padding(.vertical, 4)
                            }
                        }
                    }
                    
                    Section {
                        // Wrap the two actions in NavigationLinks
                        HStack(spacing: 12) {
                            NavigationLink(destination: EditProfileView()) {
                                ActionCard(title: "Edit Profile", systemImage: "pencil") { }
                            }
                            NavigationLink(destination: MyReportsView()) {
                                ActionCard(title: "My Reports", systemImage: "tray.full") { }
                            }
                        }
                        .listRowInsets(EdgeInsets())
                        .listRowBackground(Color.clear)
                        
                        // Leaderboard Link
                        NavigationLink(destination: LeaderboardView()) {
                            ActionCard(title: "Monthly Leaderboard", systemImage: "trophy.fill") { }
                        }
                        .listRowInsets(EdgeInsets())
                        .listRowBackground(Color.clear)
                        .padding(.top, 4)
                    }
                    
                    Section("App Info") {
                        HStack {
                            Label("Version", systemImage: "info.circle")
                            Spacer()
                            Text("1.0.0")
                                .foregroundColor(.secondary)
                        }
                        .padding(.vertical, 4)
                    }
                    
                    Section {
                        Button(action: {
                            appState.logout()
                        }) {
                            HStack {
                                Spacer()
                                Label("Logout", systemImage: "rectangle.portrait.and.arrow.right")
                                    .font(.headline)
                                    .foregroundColor(AppColors.error)
                                Spacer()
                            }
                        }
                        .contentShape(Rectangle())
                    }
                }
                .listStyle(.insetGrouped)
                .scrollContentBackground(.hidden)
                .onAppear {
                    Task {
                        await viewModel.checkCertificateStatus()
                    }
                }
                .alert(isPresented: $viewModel.showAlert) {
                    Alert(
                        title: Text("Certificate Status"),
                        message: Text(viewModel.alertMessage ?? ""),
                        dismissButton: .default(Text("OK"))
                    )
                }
            }
            .navigationTitle("Profile")
        }
    }
    
    private func profileHeader(user: User) -> some View {
        VStack(spacing: 16) {
            ZStack(alignment: .topTrailing) {
                LinearGradient(
                    colors: [AppColors.primaryBlue, AppColors.darkBlue],
                    startPoint: .topLeading, endPoint: .bottomTrailing
                )
                .frame(maxWidth: .infinity)
                .frame(height: 160)
                .cornerRadius(16)
                .overlay(
                    HStack {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack(spacing: 12) {
                                Image(systemName: "person.circle.fill")
                                    .font(.system(size: 56))
                                    .foregroundColor(.white)
                                
                                VStack(alignment: .leading, spacing: 6) {
                                    Text(user.name)
                                        .font(.headline).bold()
                                        .foregroundColor(.white)
                                    Text(user.email)
                                        .font(.subheadline)
                                        .foregroundColor(.white.opacity(0.85))
                                }
                            }
                        }
                        Spacer()
                    }
                    .padding()
                )
                .overlay(
                    StatusBadge(status: .found) // Placeholder badge
                        .padding(10),
                    alignment: .topTrailing
                )
            }
            
            statsRow
        }
    }
    
    private var statsRow: some View {
        HStack(spacing: 12) {
            StatCard(title: "Lost Reported", value: "—", systemImage: "exclamationmark.circle")
            StatCard(title: "Found Reported", value: "—", systemImage: "checkmark.circle")
            StatCard(title: "Claims", value: "—", systemImage: "doc.plaintext")
        }
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let systemImage: String
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Image(systemName: systemImage)
                    .foregroundColor(AppColors.primaryBlue)
                Spacer()
            }
            HStack {
                Text(value)
                    .font(.title3).bold()
                Spacer()
            }
            HStack {
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
                Spacer()
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(AppColors.cardBackground)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 6, x: 0, y: 3)
    }
}

struct ActionCard: View {
    let title: String
    let systemImage: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 10) {
                Image(systemName: systemImage)
                    .foregroundColor(.white)
                Text(title)
                    .font(.subheadline).bold()
                    .foregroundColor(.white)
            }
            .padding(.vertical, 12)
            .frame(maxWidth: .infinity)
            .background(
                LinearGradient(
                    colors: [AppColors.primaryBlue, AppColors.darkBlue],
                    startPoint: .topLeading, endPoint: .bottomTrailing
                )
            )
            .cornerRadius(12)
            .shadow(color: AppColors.darkBlue.opacity(0.25), radius: 8, x: 0, y: 4)
        }
        .buttonStyle(.plain)
    }
}

