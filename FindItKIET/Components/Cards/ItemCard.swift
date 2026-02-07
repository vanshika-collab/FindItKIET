//
//  ItemCard.swift
//  FindItKIET
//
//  Card component for displaying items in lists
//

import SwiftUI

struct ItemCard: View {
    let item: Item
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Image placeholder or first image
            if let firstImage = item.images?.first, let url = URL(string: firstImage.imageUrl) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .empty:
                        ZStack {
                            Rectangle()
                                .fill(Color.gray.opacity(0.15))
                            ProgressView()
                                .progressViewStyle(.circular)
                                .tint(.gray)
                        }
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    case .failure:
                        ZStack {
                            Rectangle()
                                .fill(Color.gray.opacity(0.15))
                            Image(systemName: "photo.slash")
                                .foregroundColor(.gray)
                        }
                    @unknown default:
                        ZStack {
                            Rectangle()
                                .fill(Color.gray.opacity(0.15))
                            Image(systemName: "photo")
                                .foregroundColor(.gray)
                        }
                    }
                }
                .frame(height: 180)
                .clipped()
                .cornerRadius(12)
            }
            
            // Item info
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(item.title)
                        .font(.headline)
                        .lineLimit(1)
                    
                    Spacer()
                    
                    StatusBadge(status: item.status)
                }
                
                Text(item.description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
                
                HStack {
                    if let location = item.location {
                        Label(location, systemImage: "mappin.circle.fill")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    Text(item.reportedAt, style: .relative)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 16)
        }
        .background(AppColors.cardBackground)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
}
