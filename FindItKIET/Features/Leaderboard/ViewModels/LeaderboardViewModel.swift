//
//  LeaderboardViewModel.swift
//  FindItKIET
//
//  ViewModel for leaderboard functionality
//

import Foundation
import Combine

@MainActor
class LeaderboardViewModel: ObservableObject {
    @Published var entries: [LeaderboardEntry] = []
    @Published var month: String = ""
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let apiClient = APIClient.shared
    
    func fetchLeaderboard(limit: Int = 10) async {
        isLoading = true
        errorMessage = nil
        
        do {
            let endpoint = Endpoint(
                path: "/leaderboard/monthly",
                method: .get,
                queryItems: [URLQueryItem(name: "limit", value: "\(limit)")],
                requiresAuth: false
            )
            
            let response: LeaderboardResponse = try await apiClient.request(
                endpoint,
                responseType: LeaderboardResponse.self
            )
            
            self.entries = response.leaderboard
            self.month = response.month
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    func refresh() async {
        await fetchLeaderboard()
    }
}
