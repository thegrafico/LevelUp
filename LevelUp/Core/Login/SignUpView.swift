//
//  SignUpView.swift
//  LevelUp
//
//  Created by Raúl Pichardo Avalo on 9/10/25.
//

import SwiftUI

struct SignUpView: View {
    @Environment(\.theme) private var theme
    @State private var username: String = ""
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var agree: Bool = true
    
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            TextFieldWithIcon(systemImage: "person.fill",   placeholder: "Username", text: $username)
            TextFieldWithIcon(systemImage: "envelope.fill", placeholder: "Email",    text: $email)
            TextFieldWithIcon(systemImage: "lock.fill",     placeholder: "Password", text: $password, isSecure: true)
            
            Toggle(isOn: $agree) {
                Text("I agree to the Terms & Privacy")
                    .font(.footnote)
            }
            .tint(theme.primary)
            .padding(.top, 2)
            
            PrimaryButton(title: "Create Account") {
                UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
            }
            .padding(.top, 6)
        }
        .padding(16)
        .elevatedCard(corner: theme.cornerRadiusLarge)
    }
}

#Preview {
    SignUpView()
}
