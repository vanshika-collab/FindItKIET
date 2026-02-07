//
//  AdminClaimReviewView.swift
//  FindItKIET
//
//  Admin screen to review pending claims
//

import SwiftUI

struct AdminClaimReviewView: View {
    @StateObject private var viewModel = AdminClaimsViewModel()
    
    var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()
            
            if viewModel.isLoading && viewModel.claims.isEmpty {
                LoadingView(message: "Loading pending claims...")
            } else if let error = viewModel.errorMessage {
                EmptyStateView(
                    icon: "exclamationmark.triangle",
                    title: "Error",
                    message: error,
                    actionTitle: "Retry",
                    action: {
                        Task { await viewModel.fetchPendingClaims() }
                    }
                )
            } else if viewModel.claims.isEmpty {
                EmptyStateView(
                    icon: "checkmark.shield",
                    title: "All Caught Up",
                    message: "No pending claims to review"
                )
            } else {
                ScrollView {
                    LazyVStack(spacing: 16) {
                        ForEach(viewModel.claims) { claim in
                            AdminClaimCard(
                                claim: claim,
                                onApprove: {
                                    Task { await viewModel.approveClaim(claimId: claim.id) }
                                },
                                onReject: { reason in
                                    Task { await viewModel.rejectClaim(claimId: claim.id, reason: reason) }
                                }
                            )
                        }
                    }
                    .padding()
                }
                .refreshable {
                    await viewModel.fetchPendingClaims()
                }
            }
            
            // Success Toast
            if let message = viewModel.actionMessage {
                VStack {
                    Spacer()
                    Text(message)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.black.opacity(0.8))
                        .cornerRadius(8)
                        .padding(.bottom, 20)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                viewModel.actionMessage = nil
                            }
                        }
                }
                .animation(.easeInOut, value: viewModel.actionMessage)
            }
        }
        .navigationTitle("Pending Claims")
        .task {
            await viewModel.fetchPendingClaims()
        }
    }
}

struct AdminClaimCard: View {
    let claim: Claim
    let onApprove: () -> Void
    let onReject: (String) -> Void
    
    @State private var showRejectSheet = false
    @State private var rejectReason = ""
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header: User requesting info
            HStack {
                Circle()
                    .fill(AppColors.primaryBlue.opacity(0.1))
                    .frame(width: 40, height: 40)
                    .overlay(
                        Text(claim.user?.name.prefix(1) ?? "?")
                            .font(.headline)
                            .foregroundColor(AppColors.primaryBlue)
                    )
                
                VStack(alignment: .leading) {
                    Text(claim.user?.name ?? "Unknown User")
                        .font(.headline)
                    Text(claim.user?.email ?? "No Email")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Text(claim.createdAt.formatted(date: .numeric, time: .shortened))
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            
            Divider()
            
            // Item Info
            HStack(spacing: 12) {
                if let imageUrl = claim.item?.images?.first?.imageUrl {
                    AsyncImage(url: URL(string: imageUrl)) { image in
                        image.resizable().aspectRatio(contentMode: .fill)
                    } placeholder: {
                        Color.gray.opacity(0.1)
                    }.frame(width: 60, height: 60).cornerRadius(8)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Item: \(claim.item?.title ?? "Unknown")")
                        .font(.subheadline)
                        .bold()
                    Text("Status: \(claim.item?.status.displayName ?? "Unknown")")
                        .font(.caption)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(4)
                }
            }
            .padding(.vertical, 4)
            
            // Proofs
            if let proofs = claim.proofs, !proofs.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Proofs Provided:")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.secondary)
                    
                    ForEach(proofs) { proof in
                        HStack(alignment: .top) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(AppColors.success)
                                .font(.caption)
                            
                            VStack(alignment: .leading) {
                                Text(proof.proofType)
                                    .font(.caption)
                                    .bold()
                                Text(proof.proofValue)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
                .padding(8)
                .background(AppColors.background)
                .cornerRadius(8)
            }
            
            Divider()
            
            // Actions
            HStack(spacing: 12) {
                Button(action: { showRejectSheet = true }) {
                    Text("Reject")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(AppColors.error)
                        .cornerRadius(8)
                }
                
                Button(action: onApprove) {
                    Text("Approve")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(AppColors.success)
                        .cornerRadius(8)
                }
            }
        }
        .padding()
        .background(AppColors.cardBackground)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
        .alert("Reject Claim", isPresented: $showRejectSheet) {
            TextField("Reason", text: $rejectReason)
            Button("Cancel", role: .cancel) { }
            Button("Reject", role: .destructive) {
                onReject(rejectReason.isEmpty ? "Does not meet proof requirements" : rejectReason)
                rejectReason = ""
            }
        } message: {
            Text("Please provide a reason for rejection.")
        }
    }
}
