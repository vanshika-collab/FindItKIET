//
//  LoginViewModel.swift
//  FindItKIET
//
//  Login screen view model
//

import Foundation

@MainActor
class LoginViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    var isValid: Bool {
        !email.isEmpty && !password.isEmpty && email.contains("@")
    }
    
    func login(appState: AppState) async {
        isLoading = true
        errorMessage = nil
        
        do {
            let endpoint = Endpoint(
                path: "/auth/login",
                method: .post,
                body: [
                    "email": email,
                    "password": password
                ],
                requiresAuth: false
            )
            
            let response: LoginResponse = try await APIClient.shared.request(
                endpoint,
                responseType: LoginResponse.self
            )
            
            // Save tokens and update app state
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

struct LoginResponse: Decodable {
    let user: User
    let accessToken: String
    let refreshToken: String
}
