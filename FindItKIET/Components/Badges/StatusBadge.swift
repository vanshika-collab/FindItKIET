//
//  StatusBadge.swift
//  FindItKIET
//
//  Status badge component for items and claims
//

import SwiftUI

struct StatusBadge: View {
    let status: ItemStatus
    
    var body: some View {
        Text(status.displayName.uppercased())
            .font(.caption2)
            .fontWeight(.semibold)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(backgroundColor)
            .foregroundColor(.white)
            .cornerRadius(6)
    }
    
    private var backgroundColor: Color {
        switch status {
        case .lost, .found:
            return AppColors.primaryBlue
        case .claimed:
            return AppColors.warning
        case .recovered:
            return AppColors.success
        }
    }
}

struct ClaimStatusBadge: View {
    let status: ClaimStatus
    
    var body: some View {
        Text(status.displayName.uppercased())
            .font(.caption2)
            .fontWeight(.semibold)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(backgroundColor)
            .foregroundColor(.white)
            .cornerRadius(6)
    }
    
    private var backgroundColor: Color {
        switch status {
        case .pending:
            return AppColors.warning
        case .approved:
            return AppColors.success
        case .rejected:
            return AppColors.error
        }
    }
}
