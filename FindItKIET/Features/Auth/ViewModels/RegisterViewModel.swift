//
//  RegisterViewModel.swift
//  FindItKIET
//
//  ViewModel for user registration
//

import Foundation
import Combine

@MainActor
class RegisterViewModel: ObservableObject {
    @Published var name = ""
    @Published var email = ""
    @Published var password = ""
    @Published var confirmPassword = ""
    
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    var isValid: Bool {
        !name.isEmpty &&
        !email.isEmpty &&
        email.contains("@") &&
        password.count >= 6 &&
        password == confirmPassword
    }
    
    func register(appState: AppState) async {
        guard isValid else {
            errorMessage = "Please fill all fields correctly"
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            let endpoint = Endpoint(
                path: "/auth/register",
                method: .post,
                body: [
                    "name": name,
                    "email": email,
                    "password": password
                ],
                requiresAuth: false
            )
            
            let response: AuthResponse = try await APIClient.shared.request(
                endpoint,
                responseType: AuthResponse.self
            )
            
            // Save tokens and update app state using the same flow as login
            appState.login(
                user: response.user,
                accessToken: response.accessToken,
                refreshToken: response.refreshToken
            )
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
}

struct AuthResponse: Decodable {
    let user: User
    let accessToken: String
    let refreshToken: String
}
