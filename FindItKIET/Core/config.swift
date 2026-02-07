//
//  config.swift
//  FindItKIET
//
//  Created by vanshika gupta on 07-02-2026.
//

//
//  Config.swift
//  FindItKIET
//
//  Holds environment-specific configuration
//

import Foundation

enum Config {
    // Base URL for API
    // Simulator uses localhost
    // Real device should use your Mac's local IP
    #if targetEnvironment(simulator)
    static let baseURL = "http://localhost:8000/api/v1"
    #else
    static let baseURL = "http://192.168.1.9:8000/api/v1" 
    #endif
}
