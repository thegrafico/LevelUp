//
//  CompleteButton.swift
//  LevelUp
//
//  Created by Raúl Pichardo Avalo on 9/26/25.
//

import SwiftUI

struct CompleteButton: View {
    @Environment(\.theme) private var theme
    var title: String = "COMPLETE"
    var action: () -> Void = {
        UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
    }

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.headline.weight(.heavy))
                .kerning(1)
                .foregroundStyle(theme.textInverse)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 18)
                .background(
                    LinearGradient(colors: [theme.primary, theme.primary.opacity(0.85)],
                                   startPoint: .topLeading, endPoint: .bottomTrailing)
                )
                .clipShape(RoundedRectangle(cornerRadius: theme.cornerRadiusLarge, style: .continuous))
                .shadow(color: theme.shadowDark, radius: 10, y: 8)
        }
        .buttonStyle(.plain)
        .padding(.horizontal, 20)
        .padding(.top, 12)
    }
}
#Preview {
    CompleteButton()
}
