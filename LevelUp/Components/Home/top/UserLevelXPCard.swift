//
//  UserLevelXPCard.swift
//  LevelUp
//
//  Created by Raúl Pichardo Avalo on 9/6/25.
//

import SwiftUI

struct UserLevelXPCard: View {
    var onTap: () -> Void = {
        let g = UIImpactFeedbackGenerator(style: .soft)
        g.impactOccurred()
    }

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Level 3")
                            .font(.title2.weight(.bold))
                            .foregroundStyle(.black)
                        Text("210/400 XP")
                            .font(.subheadline)
                            .foregroundStyle(.black.opacity(0.75))
                            .monospaced()
                    }
                    Spacer()
                }

                ProgressView(value: 210, total: 400) { Text("XP") }
                    .progressViewStyle(
                        ThickLinearProgressStyle(height: 22)
                    )
            }
            .padding(20)
            .contentShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
        .buttonStyle(PressableCardStyle())
        .elevatedCard(corner: 16)
        .padding(.horizontal, 20)
        .padding(.top, 8)
    }
}

struct PressableCardStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .shadow(color: .black.opacity(configuration.isPressed ? 0.04 : 0.14),
                    radius: configuration.isPressed ? 10 : 22,
                    y: configuration.isPressed ? 8 : 16)
            .animation(.spring(duration: 0.25, bounce: 0.25),
                       value: configuration.isPressed)
    }
}

#Preview {
    UserLevelXPCard()
}
