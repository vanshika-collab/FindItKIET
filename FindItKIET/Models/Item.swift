//
//  Item.swift
//  FindItKIET
//
//  Item model
//

import Foundation

struct Item: Codable, Identifiable {
    let id: String
    let title: String
    let description: String
    let category: String
    let status: ItemStatus
    let location: String?
    let reportedAt: Date
    let images: [ItemImage]?
    let createdBy: ItemCreator?
    let createdById: String
    let createdAt: Date
    let updatedAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id, title, description, category, status, location, reportedAt
        case images, createdBy, createdById, createdAt, updatedAt
    }
}

struct ItemImage: Codable, Identifiable {
    let id: String
    let imageUrl: String
}

struct ItemCreator: Codable {
    let id: String
    let name: String
    let email: String?
}

enum ItemStatus: String, Codable, CaseIterable {
    case lost = "LOST"
    case found = "FOUND"
    case claimed = "CLAIMED"
    case recovered = "RECOVERED"
    
    var displayName: String {
        switch self {
        case .lost: return "Lost"
        case .found: return "Found"
        case .claimed: return "Claimed"
        case .recovered: return "Recovered"
        }
    }
}

enum ItemCategory: String, CaseIterable {
    case electronics = "ELECTRONICS"
    case accessories = "ACCESSORIES"
    case books = "BOOKS"
    case clothing = "CLOTHING"
    case documents = "DOCUMENTS"
    case keys = "KEYS"
    case bags = "BAGS"
    case other = "OTHER"
    
    var displayName: String {
        rawValue.capitalized
    }
}
