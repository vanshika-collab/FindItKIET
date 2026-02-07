//
//  KeychainService.swift
//  FindItKIET
//
//  Secure token storage using iOS Keychain
//

import Foundation
import Security

class KeychainService {
    static let shared = KeychainService()
    private let service = "com.kiet.findit"
    
    private init() {}
    
    private enum Key: String {
        case accessToken = "accessToken"
        case refreshToken = "refreshToken"
    }
    
    // MARK: - Access Token
    
    func saveAccessToken(_ token: String) {
        save(token, forKey: .accessToken)
    }
    
    func getAccessToken() -> String? {
        return get(forKey: .accessToken)
    }
    
    func deleteAccessToken() {
        delete(forKey: .accessToken)
    }
    
    // MARK: - Refresh Token
    
    func saveRefreshToken(_ token: String) {
        save(token, forKey: .refreshToken)
    }
    
    func getRefreshToken() -> String? {
        return get(forKey: .refreshToken)
    }
    
    func deleteRefreshToken() {
        delete(forKey: .refreshToken)
    }
    
    // MARK: - Generic Keychain Operations
    
    private func save(_ value: String, forKey key: Key) {
        guard let data = value.data(using: .utf8) else { return }
        
        // Delete existing item first
        delete(forKey: key)
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key.rawValue,
            kSecValueData as String: data
        ]
        
        SecItemAdd(query as CFDictionary, nil)
    }
    
    private func get(forKey key: Key) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key.rawValue,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        guard status == errSecSuccess,
              let data = result as? Data,
              let value = String(data: data, encoding: .utf8) else {
            return nil
        }
        
        return value
    }
    
    private func delete(forKey key: Key) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key.rawValue
        ]
        
        SecItemDelete(query as CFDictionary)
    }
}
