//
//  ProfileViewModel.swift
//  FindItKIET
//
//  ViewModel for Profile actions
//

import Foundation
import Combine

@MainActor
class ProfileViewModel: ObservableObject {
    @Published var isLoading = false
    @Published var alertMessage: String?
    @Published var showAlert = false
    @Published var hasCertificate = false
    
    private let apiClient = APIClient.shared
    
    func sendCertificatesToTopReporters() async {
        isLoading = true
        
        do {
            // 1. Fetch Top 3 Reporters
            let leaderboardEndpoint = Endpoint(
                path: "/leaderboard/monthly",
                method: .get,
                queryItems: [URLQueryItem(name: "limit", value: "3")],
                requiresAuth: true
            )
            
            let leaderboardResponse: LeaderboardResponse = try await apiClient.request(
                leaderboardEndpoint,
                responseType: LeaderboardResponse.self
            )
            
            let topUsers = leaderboardResponse.leaderboard
            
            if topUsers.isEmpty {
                alertMessage = "No reporters found on the leaderboard."
                showAlert = true
                isLoading = false
                return
            }
            
            // 2. Send Certificates to each
            var successCount = 0
            
            for user in topUsers {
                // Use direct URLSession to hit port 8000 as requested
                guard let url = URL(string: "\(Config.baseURL)/generate-certificate") else { continue }
                
                var request = URLRequest(url: url)
                request.httpMethod = "POST"
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                
                let body: [String: Any] = [
                    "name": user.name,
                    "email": user.email
                ]
                request.httpBody = try? JSONSerialization.data(withJSONObject: body)
                
                // Send request
                let (data, response) = try await URLSession.shared.data(for: request)
                
                if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                    // Success on port 8000 -> Record it on port 3000
                    let recordEndpoint = Endpoint(
                        path: "/certificates/record",
                        method: .post,
                        body: ["email": user.email],
                        requiresAuth: true
                    )
                    
                    // Fire and forget verification or wait? Better to wait to ensure consistency
                    try? await apiClient.request(recordEndpoint, responseType: CertificateRecordResponse.self)
                    
                    successCount += 1
                }
                
                // Add 4 second delay between requests
                try? await Task.sleep(nanoseconds: 4 * 1_000_000_000)
            }
            
            alertMessage = "Successfully sent certificates to \(successCount) top reporters!"
            showAlert = true
            
        } catch {
            alertMessage = "Error: \(error.localizedDescription)"
            showAlert = true
        }
        
        isLoading = false
    }
    
    func checkCertificateStatus() async {
        do {
            let endpoint = Endpoint(
                path: "/certificates/me",
                method: .get,
                requiresAuth: true
            )
            
            let response: CertificateStatusResponse = try await apiClient.request(
                endpoint,
                responseType: CertificateStatusResponse.self
            )
            
            self.hasCertificate = response.hasCertificate
        } catch {
            print("Error checking certificate: \(error)")
        }
    }
}

struct CertificateRecordResponse: Codable {
    let status: String
    let message: String
}

struct CertificateStatusResponse: Codable {
    let status: String
    let hasCertificate: Bool
}
// Helper models for this specific flow
struct CertificateResponse: Codable {
    let status: String
    let message: String
}
