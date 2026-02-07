//
//  ErrorBanner.swift
//  FindItKIET
//
//  Error banner component
//

import SwiftUI

struct ErrorBanner: View {
    let message: String
    let onRetry: (() -> Void)?
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundColor(AppColors.error)
            
            Text(message)
                .font(.subheadline)
                .foregroundColor(AppColors.textPrimary)
                .lineLimit(2)
            
            Spacer()
            
            if let onRetry = onRetry {
                Button("Retry") {
                    onRetry()
                }
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(AppColors.primaryBlue)
            }
        }
        .padding()
        .background(AppColors.error.opacity(0.1))
        .cornerRadius(12)
        .padding(.horizontal)
    }
}
