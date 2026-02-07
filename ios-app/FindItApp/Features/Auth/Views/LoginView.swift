//
//  LoginView.swift
//  FindItKIET
//
//  Authentication screen
//

import SwiftUI

struct LoginView: View {
    @StateObject private var viewModel = LoginViewModel()
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            
            // Logo/Title
            VStack(spacing: 8) {
                Image(systemName: "magnifyingglass.circle.fill")
                    .font(.system(size: 80))
                    .foregroundColor(AppColors.primaryBlue)
                
                Text("FindItKIET")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("Campus Lost & Found")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // Login Form
            VStack(spacing: 16) {
                TextField("Email", text: $viewModel.email)
                    .textContentType(.emailAddress)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                    .padding()
                    .background(AppColors.cardBackground)
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(AppColors.border, lineWidth: 1)
                    )
                
                SecureField("Password", text: $viewModel.password)
                    .textContentType(.password)
                    .padding()
                    .background(AppColors.cardBackground)
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(AppColors.border, lineWidth: 1)
                    )
                
                if let error = viewModel.errorMessage {
                    Text(error)
                        .font(.caption)
                        .foregroundColor(AppColors.error)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                
                PrimaryButton(
                    title: "Login",
                    action: {
                        Task {
                            await viewModel.login(appState: appState)
                        }
                    },
                    isLoading: viewModel.isLoading,
                    isDisabled: !viewModel.isValid
                )
                .padding(.top, 8)
                
                // Register button
                Button("Create Account") {
                    // Navigate to register screen (simplified for now)
                }
                .font(.subheadline)
                .foregroundColor(AppColors.primaryBlue)
            }
            
            Spacer()
        }
        .padding(20)
        .background(AppColors.background)
    }
}
