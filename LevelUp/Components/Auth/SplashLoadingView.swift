//
//  SplashLoadingView.swift
//  LevelUp
//
//  Created by Raúl Pichardo Avalo on 10/9/25.
//

import SwiftUI

struct SplashLoadingView: View {
    @Environment(\.theme) private var theme
    @State private var animate = false

    /// Optional custom message (e.g. "Logging in...", "Signing out...")
    var message: String? = nil

    var body: some View {
        ZStack {
            theme.background.ignoresSafeArea()

            VStack(spacing: 24) {
                // ⚡ Animated Icon
                ZStack {
                    Circle()
                        .stroke(theme.primary.opacity(0.15), lineWidth: 6)
                        .frame(width: 80, height: 80)

                    Image(systemName: "bolt.fill")
                        .font(.system(size: 38, weight: .bold))
                        .foregroundStyle(theme.primary)
                        .rotationEffect(.degrees(animate ? 360 : 0))
                        .animation(
                            .linear(duration: 1)
                                .repeatForever(autoreverses: false),
                            value: animate
                        )
                }

                // 🟣 Dynamic Text
                Text(message ?? "Leveling Up...")
                    .font(.title3.weight(.bold))
                    .foregroundStyle(theme.primary)
                    .scaleEffect(animate ? 1.08 : 0.92)
                    .opacity(animate ? 1 : 0.6)
                    .animation(
                        .easeInOut(duration: 1.2)
                            .repeatForever(autoreverses: true),
                        value: animate
                    )
            }
        }
        .onAppear { animate = true }
    }
}

#Preview {
    SplashLoadingView(message: "Logging in...")
        .environment(\.theme, .orange)
}
