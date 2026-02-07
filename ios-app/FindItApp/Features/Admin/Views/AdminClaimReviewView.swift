//
//  AdminClaimReviewView.swift
//  FindItKIET
//
//  Admin claim review placeholder screen
//

import SwiftUI

struct AdminClaimReviewView: View {
    var body: some View {
        NavigationView {
            VStack {
                EmptyStateView(
                    icon: "shield.checkered",
                    title: "Admin Panel",
                    message: "Claim review and moderation tools for administrators"
                )
            }
            .background(AppColors.background)
            .navigationTitle("Admin")
        }
    }
}
