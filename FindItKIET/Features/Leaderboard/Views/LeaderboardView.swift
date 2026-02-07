//
//  LeaderboardView.swift
//  FindItKIET
//
//  Premium leaderboard UI with ranking system
//

import SwiftUI

struct LeaderboardView: View {
    @StateObject private var viewModel = LeaderboardViewModel()
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        ZStack {
            // Background
            Color("Background")
                .ignoresSafeArea()
            
            if viewModel.isLoading && viewModel.entries.isEmpty {
                ProgressView()
                    .scaleEffect(1.5)
            } else if let error = viewModel.errorMessage {
                VStack(spacing: 16) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 50))
                        .foregroundColor(.red)
                    Text("Failed to load leaderboard")
                        .font(.headline)
                    Text(error)
                        .font(.caption)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
                    Button("Retry") {
                        Task { await viewModel.refresh() }
                    }
                    .padding(.top)
                }
            } else {
                ScrollView {
                    VStack(spacing: 24) {
                        // Header
                        VStack(spacing: 8) {
                            Text(viewModel.month)
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(.secondary)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(Color.secondary.opacity(0.1))
                                .clipShape(Capsule())
                            
                            Text("Top Reporters")
                                .font(.system(size: 32, weight: .bold))
                            
                            Text("Heroes who helped return lost items")
                                .font(.body)
                                .foregroundColor(.secondary)
                        }
                        .padding(.top, 20)
                        
                        // Top 3 Podium
                        if viewModel.entries.count >= 3 {
                            HStack(alignment: .bottom, spacing: 16) {
                                // 2nd Place
                                PodiumView(entry: viewModel.entries[1], rank: 2)
                                
                                // 1st Place
                                PodiumView(entry: viewModel.entries[0], rank: 1)
                                    .scaleEffect(1.1)
                                    .zIndex(1)
                                
                                // 3rd Place
                                PodiumView(entry: viewModel.entries[2], rank: 3)
                            }
                            .padding(.horizontal)
                            .padding(.vertical, 20)
                        } else if !viewModel.entries.isEmpty {
                            // Fallback if less than 3 entries
                            ForEach(viewModel.entries) { entry in
                                LeaderboardRow(entry: entry)
                            }
                        }
                        
                        // Remaining List (4th onwards)
                        LazyVStack(spacing: 12) {
                            ForEach(viewModel.entries.dropFirst(3)) { entry in
                                LeaderboardRow(entry: entry)
                            }
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 40)
                    }
                }
                .refreshable {
                    await viewModel.refresh()
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await viewModel.fetchLeaderboard()
        }
    }
}

struct PodiumView: View {
    let entry: LeaderboardEntry
    let rank: Int
    
    var color: Color {
        switch rank {
        case 1: return .yellow
        case 2: return .gray
        case 3: return .brown // Bronze-ish
        default: return .blue
        }
    }
    
    var height: CGFloat {
        switch rank {
        case 1: return 160
        case 2: return 130
        case 3: return 110
        default: return 100
        }
    }
    
    var body: some View {
        VStack {
            // Crown for 1st place
            if rank == 1 {
                Image(systemName: "crown.fill")
                    .font(.title2)
                    .foregroundColor(.yellow)
                    .padding(.bottom, 4)
            }
            
            // Avatar Placeholder
            Circle()
                .fill(Color.secondary.opacity(0.1))
                .frame(width: 50, height: 50)
                .overlay(
                    Text(String(entry.name.prefix(1)).uppercased())
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                )
                .overlay(
                    Circle()
                        .stroke(color, lineWidth: 3)
                )
            
            Text(entry.name)
                .font(.caption)
                .fontWeight(.bold)
                .lineLimit(1)
                
            Text("\(entry.itemCount) items")
                .font(.caption2)
                .foregroundColor(.secondary)
            
            // Podium Block
            VStack {
                Text("\(rank)")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
            }
            .frame(maxWidth: .infinity)
            .frame(height: height)
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [color.opacity(0.8), color]),
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .cornerRadius(12, corners: [.topLeft, .topRight])
            .shadow(color: color.opacity(0.3), radius: 5, x: 0, y: 5)
        }
    }
}

struct LeaderboardRow: View {
    let entry: LeaderboardEntry
    
    var body: some View {
        HStack(spacing: 16) {
            Text("\(entry.rank)")
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.secondary)
                .frame(width: 30)
            
            Circle()
                .fill(Color.secondary.opacity(0.1))
                .frame(width: 40, height: 40)
                .overlay(
                    Text(String(entry.name.prefix(1)).uppercased())
                        .font(.headline)
                        .foregroundColor(.primary)
                )
            
            VStack(alignment: .leading, spacing: 4) {
                Text(entry.name)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                Text("Reported \(entry.itemCount) items")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            if entry.rank <= 10 {
                Image(systemName: "flame.fill")
                    .foregroundColor(.orange)
                    .font(.caption)
            }
        }
        .padding()
        .background(Color("Surface"))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
}

// Extension for corner radius
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}
