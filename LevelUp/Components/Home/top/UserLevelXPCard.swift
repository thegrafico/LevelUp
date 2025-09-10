//
//  UserLevelXPCard.swift
//  LevelUp
//
//  Created by Raúl Pichardo Avalo on 9/6/25.
//

import SwiftUI

struct UserLevelXPCard: View {
    @Environment(\.theme) private var theme

    var onTap: () -> Void = {
        UIImpactFeedbackGenerator(style: .soft).impactOccurred()
    }

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Level 1")
                            .font(.title2.weight(.bold))
                            .foregroundStyle(theme.textPrimary)
                            .monospaced()
                        Text("10 / 100 XP")
                            .font(theme.bodyFont)
                            .foregroundStyle(theme.textSecondary)
                            .monospaced()
                    }
                    Spacer()
                }

                ProgressView(value: 300, total: 400) { EmptyView() }
                    .progressViewStyle(ThickLinearProgressStyle(height: 22))
            }
            .padding(20)
            .contentShape(RoundedRectangle(cornerRadius: theme.cornerRadiusLarge, style: .continuous))
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

#Preview {
    UserLevelXPCard()
}
