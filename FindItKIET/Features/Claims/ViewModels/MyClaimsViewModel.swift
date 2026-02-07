//
//  MyClaimsViewModel.swift
//  FindItKIET
//
//  ViewModel for user's claims list
//

import Foundation
import Combine

@MainActor
class MyClaimsViewModel: ObservableObject {
    @Published var claims: [Claim] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let apiClient = APIClient.shared
    
    func fetchClaims() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let endpoint = Endpoint(
                path: "/claims/me", // Endpoint assumed based on typical pattern, need to verify in ClaimsController
                method: .get,
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
}
