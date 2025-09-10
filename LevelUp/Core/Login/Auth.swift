//
//  Auth.swift
//  LevelUp
//
//  Created by Raúl Pichardo Avalo on 9/10/25.
//

import SwiftUI

private enum AuthMode { case login, signup }

struct AuthView: View {
    @Environment(\.theme) private var theme
    @State private var mode: AuthMode = .login

    var body: some View {
        VStack(spacing: 0) {
            
            AuthHeader(for: mode)

            ScrollView {
                VStack(spacing: 16) {
                    if mode == .login {
                        LoginView()
                    } else {
                        SignUpView()
                    }

                    OrDivider()

                    HStack(spacing: 6) {
                        Text(mode == .login ? "New here?" : "Already have an account?")
                            .font(.footnote)
                            .foregroundStyle(theme.textSecondary)
                        Button(mode == .login ? "Create an account" : "Log in") {
                            withAnimation(.easeInOut(duration: 0.2)) { mode.toggle() }
                        }
                        .font(.footnote.weight(.semibold))
                        .foregroundStyle(theme.primary)
                        .buttonStyle(.plain)
                    }
                    .padding(.top, 6)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
            }
            .scrollIndicators(.hidden)
        }
        .background(theme.background.ignoresSafeArea())
    }
}


private extension AuthMode {
    mutating func toggle() { self = (self ==
        .login ? .signup : .login)
    }
}


#Preview {
    NavigationStack {
        AuthView()
    }
    .environment(\.theme, .orange)
}

private struct AuthHeader: View {
    @Environment(\.theme) private var theme
    var mode: AuthMode
    
    init(for mode: AuthMode) {
        self.mode = mode
    }

    var body: some View {
        VStack(spacing: 8) {
            Circle()
                .fill(theme.primary.opacity(0.12))
                .frame(width: 64, height: 64)
                .overlay(Image(systemName: "arrowtriangle.up.fill")
                    .font(.title2.weight(.bold))
                    .foregroundStyle(theme.primary))
            
            Text(mode == .login ? "Level up" : "Create Account")
                .font(.system(size: 28, weight: .black, design: .rounded))
                .kerning(1)
                .foregroundStyle(theme.textPrimary)
            
            Text(mode == .login ? "Log in to continue your streak" : "Join and start leveling up")
                .font(.subheadline)
                .foregroundStyle(theme.textSecondary)
        }
        .padding(.top, 40)
        .padding(.bottom, 16)
    }
}
