//
//  AppState.swift
//  FindItKIET
//
//  Global application state for authentication and user management
//

import Foundation
import Combine

class AppState: ObservableObject {
    @Published var isAuthenticated: Bool = false
    @Published var currentUser: User?
    
    private let keychainService = KeychainService.shared
    
    init() {
        // Check for existing tokens on app launch
        checkAuthStatus()
    }
    
    func checkAuthStatus() {
        if let accessToken = keychainService.getAccessToken(),
           !accessToken.isEmpty {
            isAuthenticated = true
            // Fetch user info
            Task {
                await fetchCurrentUser()
            }
        } else {
            isAuthenticated = false
            currentUser = nil
        }
    }
    
    @MainActor
    func fetchCurrentUser() async {
        do {
            let endpoint = Endpoint(
                path: "/auth/me",
                method: .get,
                requiresAuth: true
            )
            
            let response: FetchUserResponse = try await APIClient.shared.request(
                endpoint,
                responseType: FetchUserResponse.self
            )
            
            self.currentUser = response.user
        } catch {
            print("Error fetching user: \(error)")
            // If fetch fails (e.g. 401), allow APIClient to handle refresh
            // If completely failed, maybe logout?
            // For now, keep isAuthenticated=true but user=nil is the risk.
            // But APIClient handles 401 retry.
            // If real error, user might need to relogin.
        }
    }
    
    func login(user: User, accessToken: String, refreshToken: String) {
        keychainService.saveAccessToken(accessToken)
        keychainService.saveRefreshToken(refreshToken)
        currentUser = user
        isAuthenticated = true
    }
    
    func logout() {
        keychainService.deleteAccessToken()
        keychainService.deleteRefreshToken()
        currentUser = nil
        isAuthenticated = false
    }
}

struct FetchUserResponse: Decodable {
    let user: User
}
