//
//  User.swift
//  FindItKIET
//
//  User model
//

import Foundation

struct User: Codable, Identifiable {
    let id: String
    let email: String
    let name: String
    let role: UserRole
    let createdAt: Date?
    
    enum CodingKeys: String, CodingKey {
        case id, email, name, role, createdAt
    }
}

enum UserRole: String, Codable {
    case user = "USER"
    case admin = "ADMIN"
}
