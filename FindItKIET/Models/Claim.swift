//
//  Claim.swift
//  FindItKIET
//
//  Claim model
//

import Foundation

struct Claim: Codable, Identifiable {
    let id: String
    let status: ClaimStatus
    let adminComment: String?
    let itemId: String
    let userId: String
    let item: Item?
    let user: ClaimUser?
    let proofs: [ClaimProof]?
    let createdAt: Date
    let updatedAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id, status, adminComment, itemId, userId
        case item, user, proofs, createdAt, updatedAt
    }
}

struct ClaimProof: Codable, Identifiable {
    let id: String
    let proofType: String
    let proofValue: String
    let imageUrl: String?
    
    enum CodingKeys: String, CodingKey {
        case id, proofType, proofValue, imageUrl
    }
}

struct ClaimUser: Codable {
    let id: String
    let name: String
    let email: String?
}

enum ClaimStatus: String, Codable, CaseIterable {
    case pending = "PENDING"
    case approved = "APPROVED"
    case rejected = "REJECTED"
    
    var displayName: String {
        rawValue.capitalized
    }
}

enum ProofType: String, CaseIterable {
    case description = "DESCRIPTION"
    case serialNumber = "SERIAL_NUMBER"
    case uniqueFeature = "UNIQUE_FEATURE"
    case purchaseReceipt = "PURCHASE_RECEIPT"
    case photo = "PHOTO"
    case other = "OTHER"
    
    var displayName: String {
        switch self {
        case .description: return "Description"
        case .serialNumber: return "Serial Number"
        case .uniqueFeature: return "Unique Feature"
        case .purchaseReceipt: return "Purchase Receipt"
        case .photo: return "Photo"
        case .other: return "Other"
        }
    }
}
