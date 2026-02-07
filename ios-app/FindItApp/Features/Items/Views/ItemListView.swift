//
//  ItemListView.swift
//  FindItKIET
//
//  Home screen showing all lost/found items
//

import SwiftUI

struct ItemListView: View {
    @StateObject private var viewModel = ItemListViewModel()
    
    var body: some View {
        NavigationView {
            ZStack {
                AppColors.background.ignoresSafeArea()
                
                if viewModel.isLoading && viewModel.items.isEmpty {
                    LoadingView(message: "Loading items...")
                } else if let error = viewModel.errorMessage {
                    EmptyStateView(
                        icon: "exclamationmark.triangle",
                        title: "Error",
                        message: error,
                        actionTitle: "Retry",
                        action: {
                            Task { await viewModel.loadItems() }
                        }
                    )
                } else if viewModel.items.isEmpty {
                    EmptyStateView(
                        icon: "tray",
                        title: "No Items",
                        message: "No lost or found items yet"
                    )
                } else {
                    ScrollView {
                        VStack(spacing: 16) {
                            // Search and filters
                            searchAndFilters
                            
                            // Items grid
                            LazyVStack(spacing: 16) {
                                ForEach(viewModel.items) { item in
                                    NavigationLink(destination: ItemDetailView(itemId: item.id)) {
                                        ItemCard(item: item)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                    .refreshable {
                        await viewModel.loadItems()
                    }
                }
            }
            .navigationTitle("FindIt")
            .navigationBarTitleDisplayMode(.large)
        }
        .task {
            await viewModel.loadItems()
        }
    }
    
    private var searchAndFilters: some View {
        VStack(spacing: 12) {
            // Search bar
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                
                TextField("Search items...", text: $viewModel.searchText)
                
                if !viewModel.searchText.isEmpty {
                    Button(action: { viewModel.searchText = "" }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.gray)
                    }
                }
            }
            .padding()
            .background(AppColors.card Background)
            .cornerRadius(12)
            
            // Filter buttons
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    FilterChip(
                        title: "All",
                        isSelected: viewModel.selectedStatus == nil,
                        action: { viewModel.selectedStatus = nil }
                    )
                    
                    ForEach(ItemStatus.allCases.filter { $0 != .claimed && $0 != .recovered }, id: \.self) { status in
                        FilterChip(
                            title: status.displayName,
                            isSelected: viewModel.selectedStatus == status,
                            action: { viewModel.selectedStatus = status }
                        )
                    }
                }
            }
        }
        .padding(.horizontal)
    }
}

struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.medium)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? AppColors.primaryBlue : AppColors.cardBackground)
                .foregroundColor(isSelected ? .white : AppColors.textPrimary)
                .cornerRadius(20)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(isSelected ? Color.clear : AppColors.border, lineWidth: 1)
                )
        }
    }
}
