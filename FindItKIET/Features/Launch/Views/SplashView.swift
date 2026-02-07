//
//  SplashView.swift
//  FindItKIET
//
//  Animated splash screen with fade-out transition
//

import SwiftUI

struct SplashView: View {
    @State private var isAnimating = false
    @State private var opacity = 1.0
    @Binding var isPresented: Bool
    
    var body: some View {
        ZStack {
            // Gradient background
            LinearGradient(
                colors: [AppColors.primaryBlue, AppColors.darkBlue],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 24) {
                // Logo icon
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.2))
                        .frame(width: 120, height: 120)
                        .scaleEffect(isAnimating ? 1.1 : 1.0)
                    
                    Circle()
                        .fill(Color.white.opacity(0.3))
                        .frame(width: 100, height: 100)
                    
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 50, weight: .bold))
                        .foregroundColor(.white)
                }
                .scaleEffect(isAnimating ? 1.0 : 0.8)
                
                // App name
                VStack(spacing: 8) {
                    Text("FindItKIET")
                        .font(.system(size: 40, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text("Campus Lost & Found")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white.opacity(0.9))
                }
                .opacity(isAnimating ? 1.0 : 0.0)
            }
            .opacity(opacity)
        }
        .onAppear {
            // Start animations
            withAnimation(.easeOut(duration: 0.8)) {
                isAnimating = true
            }
            
            // Fade out and dismiss after 2 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                withAnimation(.easeOut(duration: 0.5)) {
                    opacity = 0.0
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    isPresented = false
                }
            }
        }
    }
}

#Preview {
    SplashView(isPresented: .constant(true))
}
