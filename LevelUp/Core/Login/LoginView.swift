//
//  LoginView.swift
//  LevelUp
//
//  Created by Raúl Pichardo Avalo on 9/10/25.
//

import SwiftUI


struct LoginView: View {
    @Environment(\.theme) private var theme
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var rememberMe: Bool = true
    
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            TextFieldWithIcon(systemImage: "envelope.fill", placeholder: "Email", text: $email)
            TextFieldWithIcon(systemImage: "lock.fill", placeholder: "Password", text: $password, isSecure: true)
            
            HStack {
                Toggle("Remember me", isOn: $rememberMe)
                    .font(.footnote)
                    .tint(theme.primary)
                Spacer()
                Button("Forgot password?") { }
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(theme.primary)
            }
            .padding(.top, 4)
            
            PrimaryButton(title: "Log In") {
                UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
            }
            .padding(.top, 6)
        }
        .padding(16)
        .elevatedCard(corner: theme.cornerRadiusLarge)
    }
}

#Preview {
    LoginView()
}
