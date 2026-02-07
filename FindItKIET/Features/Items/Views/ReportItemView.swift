//
//  ReportItemView.swift
//  FindItKIET
//
//  Screen for reporting lost or found items
//

import SwiftUI
import PhotosUI

struct ReportItemView: View {
    @StateObject private var viewModel = ReportItemViewModel()
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Status Toggle
                    statusToggle
                    
                    // Title Field
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Title *")
                            .font(.subheadline)
                            .fontWeight(.medium)
                        
                        TextField("e.g., Black Leather Wallet", text: $viewModel.title)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        
                        if !viewModel.title.isEmpty && viewModel.title.count < 3 {
                            Text("Title must be at least 3 characters")
                                .font(.caption)
                                .foregroundColor(AppColors.error)
                        }
                    }
                    
                    // Description Field
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Description *")
                            .font(.subheadline)
                            .fontWeight(.medium)
                        
                        TextEditor(text: $viewModel.description)
                            .frame(height: 100)
                            .padding(8)
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                        
                        if !viewModel.description.isEmpty && viewModel.description.count < 10 {
                            Text("Description must be at least 10 characters")
                                .font(.caption)
                                .foregroundColor(AppColors.error)
                        }
                    }
                    
                    // Category Picker
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Category *")
                            .font(.subheadline)
                            .fontWeight(.medium)
                        
                        Picker("Category", selection: $viewModel.category) {
                            ForEach(ItemCategory.allCases, id: \.self) { category in
                                Text(category.displayName).tag(category)
                            }
                        }
                        .pickerStyle(.menu)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                    }
                    
                    // Location Field
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Location *")
                            .font(.subheadline)
                            .fontWeight(.medium)
                        
                        TextField("e.g., Library 2nd Floor", text: $viewModel.location)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                    
                    // Date Picker
                    VStack(alignment: .leading, spacing: 8) {
                        Text("When did you \(viewModel.status == .lost ? "lose" : "find") it?")
                            .font(.subheadline)
                            .fontWeight(.medium)
                        
                        DatePicker("Date", selection: $viewModel.reportedDate, in: ...Date(), displayedComponents: [.date, .hourAndMinute])
                            .datePickerStyle(.compact)
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                    }
                    
                    // Image Upload
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Photos (Optional)")
                            .font(.subheadline)
                            .fontWeight(.medium)
                        
                        PhotosPicker(
                            selection: $viewModel.selectedPhotos,
                            maxSelectionCount: 5,
                            matching: .images
                        ) {
                            HStack {
                                Image(systemName: "photo.on.rectangle.angled")
                                Text("Add Photos (Max 5)")
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color(.systemGray6))
                            .foregroundColor(AppColors.primaryBlue)
                            .cornerRadius(8)
                        }
                        .onChange(of: viewModel.selectedPhotos) { _, _ in
                            Task {
                                await viewModel.loadImages()
                            }
                        }
                        
                        // Display selected images
                        if !viewModel.selectedImages.isEmpty {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 12) {
                                    ForEach(Array(viewModel.selectedImages.enumerated()), id: \.offset) { index, image in
                                        ZStack(alignment: .topTrailing) {
                                            Image(uiImage: image)
                                                .resizable()
                                                .scaledToFill()
                                                .frame(width: 80, height: 80)
                                                .clipShape(RoundedRectangle(cornerRadius: 8))
                                            
                                            // Remove button
                                            Button(action: {
                                                viewModel.selectedImages.remove(at: index)
                                                viewModel.selectedPhotos.remove(at: index)
                                            }) {
                                                Image(systemName: "xmark.circle.fill")
                                                    .foregroundColor(.white)
                                                    .background(Circle().fill(Color.black.opacity(0.6)))
                                            }
                                            .padding(4)
                                        }
                                    }
                                }
                                .padding(.vertical, 8)
                            }
                        }
                    }
                    
                    // Error Message
                    if let error = viewModel.errorMessage {
                        Text(error)
                            .font(.subheadline)
                            .foregroundColor(AppColors.error)
                            .padding()
                            .background(AppColors.error.opacity(0.1))
                            .cornerRadius(8)
                    }
                    
                    // Submit Button
                    PrimaryButton(
                        title: viewModel.isLoading ? "Submitting..." : "Submit Report",
                        action: {
                            Task {
                                await viewModel.submitItem()
                            }
                        },
                        isLoading: viewModel.isLoading,
                        isDisabled: !viewModel.isValidForm || viewModel.isLoading
                    )
                    .padding(.top)
                }
                .padding()
            }
            .background(AppColors.background)
            .navigationTitle("Report Item")
            .navigationBarTitleDisplayMode(.inline)
            .alert("Success!", isPresented: $viewModel.submitSuccess) {
                Button("OK") {
                    dismiss()
                }
            } message: {
                Text("Your report has been submitted successfully!")
            }
        }
    }
    
    private var statusToggle: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("What happened?")
                .font(.subheadline)
                .fontWeight(.medium)
            
            HStack(spacing: 12) {
                StatusButton(
                    title: "I Lost Something",
                    icon: "exclamationmark.triangle.fill",
                    color: AppColors.error,
                    isSelected: viewModel.status == .lost
                ) {
                    viewModel.status = .lost
                }
                
                StatusButton(
                    title: "I Found Something",
                    icon: "checkmark.circle.fill",
                    color: AppColors.success,
                    isSelected: viewModel.status == .found
                ) {
                    viewModel.status = .found
                }
            }
        }
    }
}

// MARK: - Status Button Component
struct StatusButton: View {
    let title: String
    let icon: String
    let color: Color
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 32))
                    .foregroundColor(isSelected ? color : .gray)
                
                Text(title)
                    .font(.caption)
                    .fontWeight(isSelected ? .semibold : .regular)
                    .foregroundColor(isSelected ? color : .gray)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(isSelected ? color.opacity(0.1) : Color(.systemGray6))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? color : Color.clear, lineWidth: 2)
            )
        }
    }
}

#Preview {
    ReportItemView()
}
