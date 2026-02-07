//
//  ItemDetailViewModel.swift
//  FindItKIET
//
//  Item detail view model
//

import Foundation
import Combine

@MainActor
class ItemDetailViewModel: ObservableObject {
    @Published var item: Item?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    func loadItem(itemId: String) async {
        isLoading = true
        errorMessage = nil
        
        do {
            let endpoint = Endpoint(
                path: "/items/\(itemId)",
                method: .get,
                requiresAuth: false
            )
            
            let loadedItem: Item = try await APIClient.shared.request(
                endpoint,
                responseType: Item.self
            )
            
            item = loadedItem
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
}
