//
//  ClaimSubmissionView.swift
//  FindItKIET
//
//  Claim submission form
//

import SwiftUI

struct ClaimSubmissionView: View {
    let item: Item
    @StateObject private var viewModel = ClaimSubmissionViewModel()
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                AppColors.background.ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        // Item info
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(item.title)
                                    .font(.headline)
                                Text(item.category)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                            StatusBadge(status: item.status)
                        }
                        .padding()
                        .background(AppColors.cardBackground)
                        .cornerRadius(12)
                        
                        // Instructions
                        VStack(alignment: .leading, spacing: 8) {
                            Label("Proof of Ownership", systemImage: "checkmark.shield")
                                .font(.headline)
                                .foregroundColor(AppColors.primaryBlue)
                            
                            Text("Provide evidence that this item belongs to you. Multiple proofs increase credibility.")
                                .font(.callout)
                                .foregroundColor(.secondary)
                        }
                        .padding()
                        .background(AppColors.primaryBlue.opacity(0.05))
                        .cornerRadius(12)
                        
                        // Proof entries
                        ForEach(viewModel.proofs.indices, id: \.self) { index in
                            ProofEntryCard(
                                proof: $viewModel.proofs[index],
                                onRemove: {
                                    viewModel.removeProof(at: index)
                                }
                            )
                        }
                        
                        // Add proof button
                        Button(action: {
                            viewModel.addProof()
                        }) {
                            Label("Add Another Proof", systemImage: "plus.circle.fill")
                                .font(.subheadline)
                                .fontWeight(.medium)
                        }
                        .foregroundColor(AppColors.primaryBlue)
                        
                        // Submit button
                        if let error = viewModel.errorMessage {
                            Text(error)
                                .font(.caption)
                                .foregroundColor(AppColors.error)
                                .padding()
                        }
                        
                        PrimaryButton(
                            title: "Submit Claim",
                            action: {
                                Task {
                                    await viewModel.submitClaim(itemId: item.id)
                                    if viewModel.submitSuccess {
                                        dismiss()
                                    }
                                }
                            },
                            isLoading: viewModel.isLoading,
                            isDisabled: !viewModel.isValid
                        )
                        .padding(.top, 10)
                    }
                    .padding()
                }
            }
            .navigationTitle("Submit Claim")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct ProofEntryCard: View {
    @Binding var proof: ProofEntry
    let onRemove: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Proof \(proof.id)")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Button(action: onRemove) {
                    Image(systemName: "trash")
                        .foregroundColor(AppColors.error)
                }
            }
            
            // Proof type picker
            Menu {
                ForEach(ProofType.allCases, id: \.self) { type in
                    Button(type.displayName) {
                        proof.type = type.rawValue
                    }
                }
            } label: {
                HStack {
                    Text(ProofType(rawValue: proof.type)?.displayName ?? "Select Type")
                        .foregroundColor(proof.type.isEmpty ? .secondary : .primary)
                    Spacer()
                    Image(systemName: "chevron.down")
                        .foregroundColor(.secondary)
                }
                .padding()
                .background(AppColors.cardBackground)
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(AppColors.border, lineWidth: 1)
                )
            }
            
            // Value input
            TextEditor(text: $proof.value)
                .frame(height: 80)
                .padding(8)
                .background(AppColors.cardBackground)
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(AppColors.border, lineWidth: 1)
                )
            
            // Image URL (optional)
            TextField("Image URL (optional)", text: $proof.imageUrl)
                .padding()
                .background(AppColors.cardBackground)
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(AppColors.border, lineWidth: 1)
                )
        }
        .padding()
        .background(AppColors.cardBackground)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
}

struct ProofEntry: Identifiable {
    let id: Int
    var type: String = ""
    var value: String = ""
    var imageUrl: String = ""
}
