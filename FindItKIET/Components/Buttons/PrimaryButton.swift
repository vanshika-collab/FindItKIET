//
//  PrimaryButton.swift
//  FindItKIET
//
//  Primary action button component
//

import SwiftUI

struct PrimaryButton: View {
    let title: String
    let action: () -> Void
    var isLoading: Bool = false
    var isDisabled: Bool = false
    
    var body: some View {
        Button(action: action) {
            HStack {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                } else {
                    Text(title)
                        .font(.headline)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(isDisabled ? Color.gray : AppColors.primaryBlue)
            .foregroundColor(.white)
            .cornerRadius(12)
        }
        .disabled(isDisabled || isLoading)
    }
}

struct SecondaryButton: View {
    let title: String
    let action: () -> Void
    var isDisabled: Bool = false
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.headline)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(Color.clear)
                .foregroundColor(AppColors.primaryBlue)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(AppColors.primaryBlue, lineWidth: 2)
                )
        }
        .disabled(isDisabled)
    }
}
