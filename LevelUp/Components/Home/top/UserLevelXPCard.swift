//
//  UserLevelXPCard.swift
//  LevelUp
//
//  Created by Raúl Pichardo Avalo on 9/6/25.
//

import SwiftUI

struct UserLevelXPCard: View {
    @Environment(\.theme) private var theme
    @Environment(\.currentUser) private var user
    
    var onTap: () -> Void = {
        UIImpactFeedbackGenerator(style: .soft).impactOccurred()
    }
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Level \(user.level)")
                            .font(.title2.weight(.bold))
                            .foregroundStyle(theme.textPrimary)
                            .monospaced()
                        Text("\(user.xp) / \(user.requiredXP()) XP")
                            .font(theme.bodyFont)
                            .foregroundStyle(theme.textSecondary)
                            .monospaced()
                    }
                    Spacer()
                }
                
                ProgressView(
                    value: Double(user.xp),
                    total: Double(user.requiredXP()) ) {
                        EmptyView()
                    }
                    .progressViewStyle(ThickLinearProgressStyle(height: 22))
                    .animation(.easeOut(duration: 0.6), value: user.xp) // smooth fill animation

            }
            .padding(20)
            .contentShape(
                RoundedRectangle(
                    cornerRadius: theme.cornerRadiusLarge,
                    style: .continuous)
            )
        }
        .buttonStyle(PressableCardStyleThemed())   // ← themed press style
        .elevatedCard()                            // ← themed card background + shadows + radius
        .padding(.horizontal, 20)
        .padding(.top, 8)
    }
}

struct PressableCardStyleThemed: ButtonStyle {
    @Environment(\.theme) private var theme
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .shadow(color: configuration.isPressed ? theme.shadowLight : theme.shadowDark,
                    radius: configuration.isPressed ? 10 : 22,
                    y: configuration.isPressed ? 8 : 16)
            .animation(.spring(duration: 0.25, bounce: 0.25), value: configuration.isPressed)
    }
}
struct TapBounceStyle: ButtonStyle {
    @State private var tapped = false

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.92 : (tapped ? 0.96 : 1.0))
            .animation(.spring(response: 0.25, dampingFraction: 0.7), value: configuration.isPressed)
            .animation(.spring(response: 0.25, dampingFraction: 0.7), value: tapped)
            .onChange(of: configuration.isPressed) { _, isPressed in
                if !isPressed {
                    // simulate a bounce after tap release
                    tapped = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
                        tapped = false
                    }
                }
            }
    }
}

#Preview {
    UserLevelXPCard()
        .environment(\.currentUser, User.sampleUser())
}
