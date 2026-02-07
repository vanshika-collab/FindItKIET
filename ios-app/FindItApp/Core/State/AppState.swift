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
    
    private let keychainService = KeychainService()
    
    init() {
        // Check for existing tokens on app launch
        checkAuthStatus()
    }
    
    func checkAuthStatus() {
        if let accessToken = keychainService.getAccessToken(),
           !accessToken.isEmpty {
            isAuthenticated = true
            // User info will be loaded by the appropriate view model
        } else {
            isAuthenticated = false
            currentUser = nil
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
