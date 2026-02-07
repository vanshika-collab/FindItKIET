//
//  AdminClaimsViewModel.swift
//  FindItKIET
//
//  ViewModel for admin claim review
//

import Foundation
import Combine

@MainActor
class AdminClaimsViewModel: ObservableObject {
    @Published var claims: [Claim] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var actionMessage: String?
    
    private let apiClient = APIClient.shared
    
    func fetchPendingClaims() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let endpoint = Endpoint(
                path: "/admin/claims",
                method: .get,
                queryItems: [URLQueryItem(name: "status", value: "PENDING")],
                requiresAuth: true
            )
            
            let claims: [Claim] = try await apiClient.request(
                endpoint,
                responseType: [Claim].self
            )
            
            self.claims = claims
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    func approveClaim(claimId: String, comment: String = "Approved by admin") async {
        await performAction(claimId: claimId, action: "approve", body: ["comment": comment])
    }
    
    func rejectClaim(claimId: String, reason: String) async {
        await performAction(claimId: claimId, action: "reject", body: ["reason": reason])
    }
    
    private func performAction(claimId: String, action: String, body: [String: Any]) async {
        isLoading = true
        actionMessage = nil
        errorMessage = nil
        
        do {
            let endpoint = Endpoint(
                path: "/admin/claims/\(claimId)/\(action)",
                method: .post,
                body: body,
                requiresAuth: true
            )
            
            let _: Claim = try await apiClient.request(
                endpoint,
                responseType: Claim.self
            )
            
            // Remove processed claim from list
            if let index = claims.firstIndex(where: { $0.id == claimId }) {
                claims.remove(at: index)
            }
            
            actionMessage = "Claim \(action)d successfully"
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
}
