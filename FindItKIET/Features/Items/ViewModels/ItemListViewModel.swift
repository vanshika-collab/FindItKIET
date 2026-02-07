//
//  ItemListViewModel.swift
//  FindItKIET
//
//  Item list view model
//

import Foundation
import Combine

@MainActor
class ItemListViewModel: ObservableObject {
    @Published var items: [Item] = []
    @Published var searchText = ""
    @Published var selectedStatus: ItemStatus?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    func loadItems() async {
        isLoading = true
        errorMessage = nil
        
        do {
            var queryItems: [URLQueryItem] = [
                URLQueryItem(name: "page", value: "1"),
                URLQueryItem(name: "limit", value: "20")
            ]
            
            if !searchText.isEmpty {
                queryItems.append(URLQueryItem(name: "search", value: searchText))
            }
            
            if let status = selectedStatus {
                queryItems.append(URLQueryItem(name: "status", value: status.rawValue))
            }
            
            let endpoint = Endpoint(
                path: "/items",
                method: .get,
                queryItems: queryItems,
                requiresAuth: false
            )
            
            let response: [Item] = try await APIClient.shared.request(
                endpoint,
                responseType: [Item].self
            )
            
            items = response
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
}
