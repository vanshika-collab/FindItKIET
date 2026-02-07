//
//  MyClaimsView.swift
//  FindItKIET
//
//  User's claims list placeholder screen
//

import SwiftUI

struct MyClaimsView: View {
    var body: some View {
        NavigationView {
            VStack {
                EmptyStateView(
                    icon: "checkmark.circle",
                    title: "My Claims",
                    message: "Your submitted claims will appear here"
                )
            }
            .background(AppColors.background)
            .navigationTitle("My Claims")
        }
    }
}
