//
//  RegisterView.swift
//  FindItKIET
//
//  User registration screen
//

import SwiftUI

struct RegisterView: View {
    @StateObject private var viewModel = RegisterViewModel()
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Title
                    VStack(spacing: 8) {
                        Image(systemName: "person.badge.plus")
                            .font(.system(size: 60))
                            .foregroundColor(AppColors.primaryBlue)
                        
                        Text("Create Account")
                            .font(.title)
                            .fontWeight(.bold)
                        
                        Text("Join FindItKIET community")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 20)
                    
                    // Registration Form
                    VStack(spacing: 16) {
                        // Name Field
                        TextField("Full Name", text: $viewModel.name)
                            .textContentType(.name)
                            .autocapitalization(.words)
                            .padding()
                            .background(AppColors.cardBackground)
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(AppColors.border, lineWidth: 1)
                            )
                        
                        // Email Field
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
                        
                        // Password Field
                        SecureField("Password", text: $viewModel.password)
                            .textContentType(.newPassword)
                            .padding()
                            .background(AppColors.cardBackground)
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(AppColors.border, lineWidth: 1)
                            )
                        
                        if !viewModel.password.isEmpty && viewModel.password.count < 6 {
                            Text("Password must be at least 6 characters")
                                .font(.caption)
                                .foregroundColor(AppColors.error)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        
                        // Confirm Password Field
                        SecureField("Confirm Password", text: $viewModel.confirmPassword)
                            .textContentType(.newPassword)
                            .padding()
                            .background(AppColors.cardBackground)
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(AppColors.border, lineWidth: 1)
                            )
                        
                        if !viewModel.confirmPassword.isEmpty && viewModel.password != viewModel.confirmPassword {
                            Text("Passwords do not match")
                                .font(.caption)
                                .foregroundColor(AppColors.error)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        
                        // Error Message
                        if let error = viewModel.errorMessage {
                            Text(error)
                                .font(.caption)
                                .foregroundColor(AppColors.error)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        
                        // Register Button
                        PrimaryButton(
                            title: "Create Account",
                            action: {
                                Task {
                                    await viewModel.register(appState: appState)
                                }
                            },
                            isLoading: viewModel.isLoading,
                            isDisabled: !viewModel.isValid
                        )
                        .padding(.top, 8)
                        
                        // Back to Login
                        Button("Already have an account? Login") {
                            dismiss()
                        }
                        .font(.subheadline)
                        .foregroundColor(AppColors.primaryBlue)
                    }
                    .padding(.horizontal)
                }
            }
            .background(AppColors.background)
            .navigationBarHidden(true)
        }
    }
}

#Preview {
    RegisterView()
        .environmentObject(AppState())
}
