//
//  AppColors.swift
//  FindItKIET
//
//  Minimal, professional color system
//

import SwiftUI

struct AppColors {
    // MARK: - Primary
    static let primaryBlue = Color(hex: "2563EB")
    static let darkBlue = Color(hex: "1E40AF")
    
    // MARK: - Neutral
    static let background = Color(hex: "F8FAFC")
    static let cardBackground = Color.white
    static let border = Color(hex: "E5E7EB")
    static let textPrimary = Color.black
    static let textSecondary = Color.gray
    
    // MARK: - Status
    static let success = Color(hex: "16A34A")
    static let warning = Color(hex: "F59E0B")
    static let error = Color(hex: "DC2626")
}

// MARK: - Color Extension for Hex Support
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
