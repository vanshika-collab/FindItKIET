//
//  ClaimSubmissionViewModel.swift
//  FindItKIET
//
//  Claim submission view model
//

import Foundation

@MainActor
class ClaimSubmissionViewModel: ObservableObject {
    @Published var proofs: [ProofEntry] = [ProofEntry(id: 1)]
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var submitSuccess = false
    
    private var nextProofId = 2
    
    var isValid: Bool {
        // At least one proof with type and value
        proofs.contains { !$0.type.isEmpty && !$0.value.isEmpty }
    }
    
    func addProof() {
        proofs.append(ProofEntry(id: nextProofId))
        nextProofId += 1
    }
    
    func removeProof(at index: Int) {
        guard proofs.count > 1 else { return }
        proofs.remove(at: index)
    }
    
    func submitClaim(itemId: String) async {
        isLoading = true
        errorMessage = nil
        submitSuccess = false
        
        do {
            // Filter valid proofs only
            let validProofs = proofs
                .filter { !$0.type.isEmpty && !$0.value.isEmpty }
                .map { proof -> [String: Any] in
                    var dict: [String: Any] = [
                        "type": proof.type,
                        "value": proof.value
                    ]
                    if !proof.imageUrl.isEmpty {
                        dict["imageUrl"] = proof.imageUrl
                    }
                    return dict
                }
            
            let endpoint = Endpoint(
                path: "/items/\(itemId)/claims",
                method: .post,
                body: ["proofs": validProofs],
                requiresAuth: true
            )
            
            let _: Claim = try await APIClient.shared.request(
                endpoint,
                responseType: Claim.self
            )
            
            submitSuccess = true
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
}
