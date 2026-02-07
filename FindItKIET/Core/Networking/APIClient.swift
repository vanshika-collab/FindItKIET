//
//  APIClient.swift
//  FindItKIET
//
//  Centralized HTTP client for API communication
//

import Foundation

class APIClient {
    static let shared = APIClient()
    
    private let baseURL: String
    
    private let keychainService = KeychainService.shared
    
    // Shared configured JSONDecoder
    private let decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        // Use ISO8601 with fractional seconds to match "2026-02-03T08:37:13.247Z"
        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        decoder.dateDecodingStrategy = .custom { decoder in
            let container = try decoder.singleValueContainer()
            let string = try container.decode(String.self)
            if let date = isoFormatter.date(from: string) {
                return date
            }
            // Fallback to plain ISO8601 without fractional seconds, just in case
            let plainISO = ISO8601DateFormatter()
            if let date = plainISO.date(from: string) {
                return date
            }
            // Or try RFC3339 formatter if needed
            let rfc = DateFormatter()
            rfc.locale = Locale(identifier: "en_US_POSIX")
            rfc.timeZone = TimeZone(secondsFromGMT: 0)
            rfc.dateFormat = "yyyy-MM-dd'T'HH:mm:ssXXXXX"
            if let date = rfc.date(from: string) {
                return date
            }
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Invalid date: \(string)")
        }
        // Keep keys as-is; your JSON uses camelCase matching your models
        decoder.keyDecodingStrategy = .useDefaultKeys
        return decoder
    }()
    
    private init() {
        // Configure base URL (can be moved to environment configuration)
        baseURL = Config.baseURL
    }
    
    // MARK: - Request Method
    
    func request<T: Decodable>(
        _ endpoint: Endpoint,
        responseType: T.Type
    ) async throws -> T {
        // Build URL
        var urlComponents = URLComponents(string: "\(baseURL)\(endpoint.path)")
        if let queryItems = endpoint.queryItems, !queryItems.isEmpty {
            urlComponents?.queryItems = queryItems
        }
        guard let url = urlComponents?.url else {
            throw APIError.invalidURL
        }
        
        // Create request
        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Add authorization header if required
        if endpoint.requiresAuth {
            guard let token = keychainService.getAccessToken() else {
                throw APIError.unauthorized
            }
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        // Add body if present
        if let body = endpoint.body {
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
        }
        
        // Perform request
        let (data, response) = try await URLSession.shared.data(for: request)
        
        // Check response status
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }
        
        // Handle different status codes
        switch httpResponse.statusCode {
        case 200...299:
            // Success - decode response
            do {
                let apiResponse = try decoder.decode(APIResponse<T>.self, from: data)
                guard let resultData = apiResponse.data else {
                    throw APIError.noData
                }
                return resultData
            } catch {
                throw APIError.decodingError(error)
            }
            
        case 401:
            // Unauthorized - try to refresh token
            try await refreshToken()
            // Retry the original request
            return try await self.request(endpoint, responseType: responseType)
            
        case 400...499:
            // Client error
            let errorResponse = try? decoder.decode(APIErrorResponse.self, from: data)
            throw APIError.clientError(errorResponse?.error.message ?? "Client error")
            
        case 500...599:
            // Server error
            throw APIError.serverError
            
        default:
            throw APIError.unknown
        }
    }
    
    // MARK: - Token Refresh
    
    private func refreshToken() async throws {
        guard let refreshToken = keychainService.getRefreshToken() else {
            throw APIError.unauthorized
        }
        
        let endpoint = Endpoint(
            path: "/auth/refresh",
            method: .post,
            body: ["refreshToken": refreshToken],
            requiresAuth: false
        )
        
        let response: RefreshTokenResponse = try await self.request(endpoint, responseType: RefreshTokenResponse.self)
        
        // Save new tokens
        keychainService.saveAccessToken(response.accessToken)
        keychainService.saveRefreshToken(response.refreshToken)
    }
}

// MARK: - Endpoint

struct Endpoint {
    let path: String
    let method: HTTPMethod
    var body: [String: Any]?
    var queryItems: [URLQueryItem]?
    var requiresAuth: Bool
    
    init(
        path: String,
        method: HTTPMethod,
        body: [String: Any]? = nil,
        queryItems: [URLQueryItem]? = nil,
        requiresAuth: Bool = false
    ) {
        self.path = path
        self.method = method
        self.body = body
        self.queryItems = queryItems
        self.requiresAuth = requiresAuth
    }
}

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case patch = "PATCH"
    case delete = "DELETE"
}

// MARK: - API Response Models

struct APIResponse<T: Decodable>: Decodable {
    let success: Bool
    let data: T?
    let error: ErrorData?
    let meta: MetaData?
}

struct APIErrorResponse: Decodable {
    let success: Bool
    let error: ErrorData
}

struct ErrorData: Decodable {
    let code: String
    let message: String
    let details: [String: String]?
}

struct MetaData: Decodable {
    let page: Int?
    let limit: Int?
    let total: Int?
    let totalPages: Int?
}

struct RefreshTokenResponse: Decodable {
    let accessToken: String
    let refreshToken: String
}

// MARK: - API Errors

enum APIError: LocalizedError {
    case invalidURL
    case unauthorized
    case invalidResponse
    case noData
    case decodingError(Error)
    case clientError(String)
    case serverError
    case unknown
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .unauthorized:
            return "Please login again"
        case .invalidResponse:
            return "Invalid response from server"
        case .noData:
            return "No data received"
        case .decodingError(let error):
                return "Data parsing error: \(error.localizedDescription)"
        case .clientError(let message):
            return message
        case .serverError:
            return "Server error. Please try again later"
        case .unknown:
            return "An unknown error occurred"
        }
    }
}
