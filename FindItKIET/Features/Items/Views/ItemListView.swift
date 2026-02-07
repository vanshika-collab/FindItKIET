//
//  ItemListView.swift
//  FindItKIET
//
//  Home screen showing all lost/found items
//

import SwiftUI

struct ItemListView: View {
    @StateObject private var viewModel = ItemListViewModel()
    @Namespace private var chipAnimation
    
    // Sheet presentation for reporting flows
    @State private var showReportSheet = false
    @State private var reportPresetStatus: ItemStatus? = nil
    
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
                        VStack(spacing: 20) {
                            heroHeader
                            searchAndFilters
                            
                            sectionHeader(title: "Recently Reported")
                                .padding(.horizontal)
                            
                            LazyVStack(spacing: 16) {
                                ForEach(viewModel.items) { item in
                                    NavigationLink(destination: ItemDetailView(itemId: item.id)) {
                                        ItemCard(item: item)
                                            .background(AppColors.cardBackground)
                                            .cornerRadius(12)
                                            .shadow(color: Color.black.opacity(0.05), radius: 6, x: 0, y: 3)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }
                            .padding(.horizontal)
                        }
                        .padding(.vertical)
                    }
                    .refreshable {
                        await viewModel.loadItems()
                    }
                }
            }
            .navigationTitle("FindIt")
            .navigationBarTitleDisplayMode(.large)
        }
        .sheet(isPresented: $showReportSheet) {
            // For now, we just show the placeholder ReportItemView.
            // If you later add an initializer to take a preset status, pass it here.
            ReportItemView()
        }
        .task {
            await viewModel.loadItems()
        }
    }
    
    private var heroHeader: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .center) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Welcome to")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.85))
                    Text("FindIt KIET")
                        .font(.title2).bold()
                        .foregroundColor(.white)
                }
                Spacer()
                Image(systemName: "magnifyingglass.circle.fill")
                    .font(.system(size: 36, weight: .semibold))
                    .foregroundColor(.white.opacity(0.95))
            }
            
            HStack(spacing: 12) {
                QuickActionButton(
                    title: "Report Lost",
                    systemImage: "exclamationmark.bubble.fill",
                    background: LinearGradient(
                        colors: [AppColors.primaryBlue, AppColors.darkBlue],
                        startPoint: .topLeading, endPoint: .bottomTrailing
                    ),
                    foreground: .white
                ) {
                    reportPresetStatus = .lost
                    showReportSheet = true
                }
                
                QuickActionButton(
                    title: "Report Found",
                    systemImage: "checkmark.seal.fill",
                    background: LinearGradient(
                        colors: [AppColors.success, AppColors.primaryBlue],
                        startPoint: .topLeading, endPoint: .bottomTrailing
                    ),
                    foreground: .white
                ) {
                    reportPresetStatus = .found
                    showReportSheet = true
                }
            }
        }
        .padding()
        .background(
            LinearGradient(
                colors: [AppColors.primaryBlue, AppColors.darkBlue],
                startPoint: .topLeading, endPoint: .bottomTrailing
            )
            .cornerRadius(16)
        )
        .shadow(color: AppColors.darkBlue.opacity(0.25), radius: 10, x: 0, y: 6)
        .padding(.horizontal)
        .padding(.top, 4)
    }
    
    private var searchAndFilters: some View {
        VStack(spacing: 12) {
            // Search bar
            HStack(spacing: 8) {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                
                TextField("Search items...", text: $viewModel.searchText)
                    .textInputAutocapitalization(.never)
                    .disableAutocorrection(true)
                    .submitLabel(.search)
                    .onSubmit {
                        Task { await viewModel.loadItems() }
                    }
                
                if !viewModel.searchText.isEmpty {
                    Button(action: {
                        viewModel.searchText = ""
                        Task { await viewModel.loadItems() }
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.gray)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .background(AppColors.cardBackground)
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
            
            // Filter buttons
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    AnimatedFilterChip(
                        title: "All",
                        isSelected: viewModel.selectedStatus == nil,
                        namespace: chipAnimation,
                        action: {
                            withAnimation(.spring(response: 0.25, dampingFraction: 0.8)) { viewModel.selectedStatus = nil }
                            Task { await viewModel.loadItems() }
                        }
                    )
                    
                    ForEach(ItemStatus.allCases.filter { $0 != .claimed && $0 != .recovered }, id: \.self) { status in
                        AnimatedFilterChip(
                            title: status.displayName,
                            isSelected: viewModel.selectedStatus == status,
                            namespace: chipAnimation,
                            action: {
                                withAnimation(.spring(response: 0.25, dampingFraction: 0.8)) { viewModel.selectedStatus = status }
                                Task { await viewModel.loadItems() }
                            }
                        )
                    }
                }
                .padding(.horizontal, 2)
            }
        }
        .padding(.horizontal)
    }
    
    private func sectionHeader(title: String) -> some View {
        HStack {
            Text(title)
                .font(.headline)
            Spacer()
        }
        .padding(.top, 4)
    }
}

struct QuickActionButton: View {
    let title: String
    let systemImage: String
    let background: LinearGradient
    let foreground: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: systemImage)
                    .font(.subheadline)
                Text(title)
                    .font(.subheadline).bold()
            }
            .foregroundColor(foreground)
            .padding(.vertical, 10)
            .frame(maxWidth: .infinity)
            .background(background)
            .cornerRadius(12)
        }
        .buttonStyle(.plain)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 3)
    }
}

struct AnimatedFilterChip: View {
    let title: String
    let isSelected: Bool
    let namespace: Namespace.ID
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            ZStack {
                if isSelected {
                    RoundedRectangle(cornerRadius: 18)
                        .fill(
                            LinearGradient(
                                colors: [AppColors.primaryBlue, AppColors.darkBlue],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .matchedGeometryEffect(id: "chip_bg_\(title)", in: namespace)
                } else {
                    RoundedRectangle(cornerRadius: 18)
                        .fill(AppColors.cardBackground)
                        .overlay(
                            RoundedRectangle(cornerRadius: 18)
                                .stroke(AppColors.border, lineWidth: 1)
                        )
                }
                
                Text(title)
                    .font(.subheadline).fontWeight(.medium)
                    .foregroundColor(isSelected ? .white : AppColors.textPrimary)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
            }
        }
        .buttonStyle(.plain)
        .scaleEffect(isSelected ? 1.02 : 1.0)
        .animation(.spring(response: 0.25, dampingFraction: 0.85), value: isSelected)
    }
}

