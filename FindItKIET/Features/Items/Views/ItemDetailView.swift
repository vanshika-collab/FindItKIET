//
//  ItemDetailView.swift
//  FindItKIET
//
//  Item detail screen with claim submission
//

import SwiftUI

struct ItemDetailView: View {
    let itemId: String
    @StateObject private var viewModel = ItemDetailViewModel()
    @Environment(\.dismiss) var dismiss
    @State private var showClaimSheet = false
    
    var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()
            
            if viewModel.isLoading {
                LoadingView(message: "Loading item...")
            } else if let error = viewModel.errorMessage {
                EmptyStateView(
                    icon: "exclamationmark.triangle",
                    title: "Error",
                    message: error,
                    actionTitle: "Retry",
                    action: {
                        Task { await viewModel.loadItem(itemId: itemId) }
                    }
                )
            } else if let item = viewModel.item {
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        // Image carousel
                        if let images = item.images, !images.isEmpty {
                            TabView {
                                ForEach(images) { image in
                                    AsyncImage(url: URL(string: image.imageUrl)) { image in
                                        image
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                    } placeholder: {
                                        Rectangle()
                                            .fill(Color.gray.opacity(0.2))
                                            .overlay(
                                                ProgressView()
                                            )
                                    }
                                    .frame(height: 300)
                                    .clipped()
                                }
                            }
                            .frame(height: 300)
                            .tabViewStyle(.page)
                        }
                        
                        VStack(alignment: .leading, spacing: 16) {
                            // Header
                            HStack {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text(item.title)
                                        .font(.title)
                                        .fontWeight(.bold)
                                    
                                    HStack {
                                        StatusBadge(status: item.status)
                                        Text(item.category)
                                            .font(.caption)
                                            .padding(.horizontal, 10)
                                            .padding(.vertical, 5)
                                            .background(AppColors.primaryBlue.opacity(0.1))
                                            .foregroundColor(AppColors.primaryBlue)
                                            .cornerRadius(6)
                                    }
                                }
                                Spacer()
                            }
                            
                            Divider()
                            
                            // Description
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Description")
                                    .font(.headline)
                                
                                Text(item.description)
                                    .font(.body)
                                    .foregroundColor(.secondary)
                            }
                            
                            Divider()
                            
                            // Details
                            VStack(alignment: .leading, spacing: 12) {
                                if let location = item.location {
                                    DetailRow(
                                        icon: "mappin.circle.fill",
                                        label: "Location",
                                        value: location
                                    )
                                }
                                
                                DetailRow(
                                    icon: "calendar",
                                    label: "Reported",
                                    value: item.reportedAt.formatted(date: .abbreviated, time: .shortened)
                                )
                                
                                if let creator = item.createdBy {
                                    DetailRow(
                                        icon: "person.fill",
                                        label: "Reported by",
                                        value: creator.name
                                    )
                                }
                            }
                            
                            // Claim button (only for LOST or FOUND items)
                            if item.status == .lost || item.status == .found {
                                PrimaryButton(
                                    title: "Submit Claim",
                                    action: {
                                        showClaimSheet = true
                                    }
                                )
                                .padding(.top, 20)
                            } else if item.status == .claimed {
                                HStack {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(AppColors.warning)
                                    Text("This item has pending claims")
                                        .font(.subheadline)
                                }
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(AppColors.warning.opacity(0.1))
                                .cornerRadius(12)
                            } else if item.status == .recovered {
                                HStack {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(AppColors.success)
                                    Text("This item has been recovered")
                                        .font(.headline)
                                }
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(AppColors.success.opacity(0.1))
                                .cornerRadius(12)
                            }
                        }
                        .padding()
                    }
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showClaimSheet, onDismiss: {
            Task {
                await viewModel.loadItem(itemId: itemId)
            }
        }) {
            if let item = viewModel.item {
                ClaimSubmissionView(item: item)
            }
        }
        .task {
            await viewModel.loadItem(itemId: itemId)
        }
    }
}

struct DetailRow: View {
    let icon: String
    let label: String
    let value: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(AppColors.primaryBlue)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text(value)
                    .font(.body)
            }
        }
    }
}
