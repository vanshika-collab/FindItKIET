//
//  ImageUploadService.swift
//  FindItKIET
//
//  Service for uploading images to the backend
//

import Foundation
import UIKit

class ImageUploadService {
    static let shared = ImageUploadService()
    private let baseURL = "http://localhost:8000/api/v1/upload"
    
    private init() {}
    
    // Upload single image
    func uploadImage(_ image: UIImage) async throws -> String {
        guard let imageData = image.jpegData(compressionQuality: 0.7) else {
            throw UploadError.invalidImage
        }
        
        let endpoint = "\(baseURL)/single"
        guard let url = URL(string: endpoint) else {
            throw UploadError.invalidURL
        }
        
        // Create multipart form data
        let boundary = UUID().uuidString
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        // Add auth token
        if let token = KeychainService.shared.getAccessToken() {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        // Build multipart body
        var body = Data()
        
        // Add image data
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"image\"; filename=\"image.jpg\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
        body.append(imageData)
        body.append("\r\n".data(using: .utf8)!)
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        
        request.httpBody = body
        
        // Perform upload
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw UploadError.uploadFailed
        }
        
        // Parse response
        let uploadResponse = try JSONDecoder().decode(UploadResponse.self, from: data)
        guard let imageUrl = uploadResponse.data?.url else {
            throw UploadError.noURL
        }
        
        return imageUrl
    }
    
    // Upload multiple images
    func uploadImages(_ images: [UIImage]) async throws -> [String] {
        guard !images.isEmpty else { return [] }
        
        let endpoint = "\(baseURL)/multiple"
        guard let url = URL(string: endpoint) else {
            throw UploadError.invalidURL
        }
        
        // Create multipart form data
        let boundary = UUID().uuidString
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        // Add auth token
        if let token = KeychainService.shared.getAccessToken() {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        // Build multipart body
        var body = Data()
        
        for (index, image) in images.enumerated() {
            guard let imageData = image.jpegData(compressionQuality: 0.7) else { continue }
            
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"images\"; filename=\"image\(index).jpg\"\r\n".data(using: .utf8)!)
            body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
            body.append(imageData)
            body.append("\r\n".data(using: .utf8)!)
        }
        
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        request.httpBody = body
        
        // Perform upload
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw UploadError.uploadFailed
        }
        
        // Parse response
        let uploadResponse = try JSONDecoder().decode(MultipleUploadResponse.self, from: data)
        guard let images = uploadResponse.data?.images else {
            throw UploadError.noURL
        }
        
        return images.map { $0.url }
    }
}

// MARK: - Response Models

struct UploadResponse: Codable {
    let success: Bool
    let data: UploadData?
}

struct UploadData: Codable {
    let filename: String
    let url: String
    let size: Int
    let mimetype: String
}

struct MultipleUploadResponse: Codable {
    let success: Bool
    let data: MultipleUploadData?
}

struct MultipleUploadData: Codable {
    let count: Int
    let images: [UploadData]
}

// MARK: - Errors

enum UploadError: LocalizedError {
    case invalidImage
    case invalidURL
    case uploadFailed
    case noURL
    
    var errorDescription: String? {
        switch self {
        case .invalidImage:
            return "Could not process image"
        case .invalidURL:
            return "Invalid upload URL"
        case .uploadFailed:
            return "Image upload failed"
        case .noURL:
            return "No image URL received"
        }
    }
}
