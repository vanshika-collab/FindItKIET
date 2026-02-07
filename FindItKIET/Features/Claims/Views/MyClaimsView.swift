//
//  MyClaimsView.swift
//  FindItKIET
//
//  User's claims list screen
//

import SwiftUI

struct MyClaimsView: View {
    @StateObject private var viewModel = MyClaimsViewModel()
    
    var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()
            
            if viewModel.isLoading && viewModel.claims.isEmpty {
                LoadingView(message: "Loading claims...")
            } else if let error = viewModel.errorMessage {
                EmptyStateView(
                    icon: "exclamationmark.triangle",
                    title: "Error",
                    message: error,
                    actionTitle: "Retry",
                    action: {
                        Task { await viewModel.fetchClaims() }
                    }
                )
            } else if viewModel.claims.isEmpty {
                EmptyStateView(
                    icon: "doc.text.magnifyingglass",
                    title: "No Claims Yet",
                    message: "Claims you submit for lost items will appear here"
                )
            } else {
                ScrollView {
                    LazyVStack(spacing: 16) {
                        ForEach(viewModel.claims) { claim in
                            NavigationLink(destination: ClaimDetailView(claim: claim)) {
                                ClaimRowView(claim: claim)
                            }
                        }
                    }
                    .padding()
                }
                .refreshable {
                    await viewModel.fetchClaims()
                }
            }
        }
        .navigationTitle("My Claims")
        .task {
            await viewModel.fetchClaims()
        }
    }
}

struct ClaimRowView: View {
    let claim: Claim
    
    var statusColor: Color {
        switch claim.status {
        case .pending: return AppColors.warning
        case .approved: return AppColors.success
        case .rejected: return AppColors.error
        }
    }
    
    var body: some View {
        HStack(spacing: 16) {
            // Item Image Thumb
            if let imageUrl = claim.item?.images?.first?.imageUrl {
                AsyncImage(url: URL(string: imageUrl)) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Color.gray.opacity(0.1)
                }
                .frame(width: 60, height: 60)
                .cornerRadius(8)
            } else {
                Rectangle()
                    .fill(Color.gray.opacity(0.1))
                    .frame(width: 60, height: 60)
                    .cornerRadius(8)
                    .overlay(
                        Image(systemName: "photo")
                            .foregroundColor(.secondary)
                    )
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(claim.item?.title ?? "Unknown Item")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text("Reported on \(claim.createdAt.formatted(date: .abbreviated, time: .omitted))")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                HStack {
                    StatusBadge(status: claim.item?.status ?? .claimed)
                        .scaleEffect(0.8)
                    Spacer()
                }
            }
            
            Spacer()
            
            VStack {
                Text(claim.status.rawValue)
                    .font(.caption)
                    .fontWeight(.bold)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(statusColor.opacity(0.1))
                    .foregroundColor(statusColor)
                    .cornerRadius(4)
                
                Spacer()
            }
        }
        .padding()
        .background(AppColors.cardBackground)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
}

// Minimal Detail View for Claim
struct ClaimDetailView: View {
    let claim: Claim
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Item Info
                VStack(alignment: .leading, spacing: 8) {
                    Text("Item Details")
                        .font(.headline)
                    Divider()
                    Text(claim.item?.title ?? "Unknown")
                        .font(.title2)
                        .bold()
                }
                .padding()
                .background(AppColors.cardBackground)
                .cornerRadius(12)
                
                // Status
                VStack(alignment: .leading, spacing: 8) {
                    Text("Claim Status")
                        .font(.headline)
                    Divider()
                    HStack {
                        Text(claim.status.rawValue)
                            .font(.title3)
                            .bold()
                            .foregroundColor(statusColor)
                        Spacer()
                    }
                    
                    if let comment = claim.adminComment {
                        Text("Admin Comment:")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .padding(.top, 4)
                        Text(comment)
                            .font(.body)
                    }
                }
                .padding()
                .background(AppColors.cardBackground)
                .cornerRadius(12)
                
                // Proofs
                if let proofs = claim.proofs {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Submitted Proofs")
                            .font(.headline)
                        Divider()
                        ForEach(proofs) { proof in
                            VStack(alignment: .leading, spacing: 4) {
                                Text(proof.proofType)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Text(proof.proofValue)
                                    .font(.body)
                            }
                            .padding(.vertical, 4)
                        }
                    }
                    .padding()
                    .background(AppColors.cardBackground)
                    .cornerRadius(12)
                }
            }
            .padding()
        }
        .background(AppColors.background)
        .navigationTitle("Claim Details")
    }
    
    var statusColor: Color {
        switch claim.status {
        case .pending: return AppColors.warning
        case .approved: return AppColors.success
        case .rejected: return AppColors.error
        }
    }
}
