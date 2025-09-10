//
//  AuthButtons.swift
//  LevelUp
//
//  Created by Raúl Pichardo Avalo on 9/10/25.
//

import SwiftUI

struct AuthButtons: View {
    var body: some View {
        PrimaryButton(title: "Login", action: {})
        
        OrDivider()
        OAuthButtonsRow()
        
        OrDivider()
        OAuthButton(title: "Test", icon: "plus.circle")
    }
}

struct OAuthButton: View {
    @Environment(\.theme) private var theme
    var title: String
    var icon: String
    var body: some View {
        Button {
            UIImpactFeedbackGenerator(style: .soft).impactOccurred()
        } label: {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .semibold))
                Text(title)
                    .font(.subheadline.weight(.semibold))
            }
            .foregroundStyle(theme.textPrimary)
            .padding(.vertical, 12)
            .frame(maxWidth: .infinity)
            .background(theme.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: theme.cornerRadiusSmall, style: .continuous))
            .shadow(color: theme.shadowLight, radius: 4, y: 2)
        }
        .buttonStyle(.plain)
    }
}

struct OAuthButtonsRow: View {
    @Environment(\.theme) private var theme
    var body: some View {
        HStack(spacing: 12) {
            OAuthButton(title: "Sign in with Apple", icon: "apple.logo")
            OAuthButton(title: "Continue with Google", icon: "g.circle.fill")
        }
    }
}

struct PrimaryButton: View {
    @Environment(\.theme) private var theme
    var title: String
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title.uppercased())
                .font(.headline.weight(.heavy))
                .kerning(1)
                .foregroundStyle(theme.textInverse)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    LinearGradient(colors: [theme.primary, theme.primary.opacity(0.85)],
                                   startPoint: .topLeading, endPoint: .bottomTrailing)
                )
                .clipShape(RoundedRectangle(cornerRadius: theme.cornerRadiusLarge, style: .continuous))
                .shadow(color: theme.shadowDark, radius: 10, y: 8)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    AuthButtons()
}
