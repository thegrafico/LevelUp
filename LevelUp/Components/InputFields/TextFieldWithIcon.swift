//
//  TextFieldWithIcon.swift
//  LevelUp
//
//  Created by Raúl Pichardo Avalo on 9/10/25.
//
import SwiftUI

struct TextFieldWithIcon: View {
    @Environment(\.theme) private var theme

    var systemImage: String
    var placeholder: String
    @Binding var text: String
    var isSecure: Bool = false

    // 👇 Add these parameters
    var isInvalid: Bool = false
    var errorText: String? = nil

    @State private var reveal = false

    var body: some View {
        HStack(spacing: 10) {
            ZStack {
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(theme.primary.opacity(0.12))
                    .frame(width: 36, height: 36)
                Image(systemName: systemImage)
                    .foregroundStyle(isInvalid ? .red : theme.primary)
                    .font(.system(size: 16, weight: .semibold))
            }

            if isSecure && !reveal {
                SecureField(placeholder, text: $text)
                    .textContentType(.password)
                    .foregroundColor(isInvalid ? .red : theme.textPrimary)
            } else {
                TextField(placeholder, text: $text)
                    .textInputAutocapitalization(.never)
                    .textContentType(isSecure ? .password : .username)
                    .autocorrectionDisabled(true)
                    .foregroundColor(isInvalid ? .red : theme.textPrimary)
            }

            if isSecure {
                Button {
                    withAnimation(.easeInOut(duration: 0.15)) { reveal.toggle() }
                } label: {
                    Image(systemName: reveal ? "eye.slash.fill" : "eye.fill")
                        .foregroundStyle(theme.textSecondary)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 12)
        .background(theme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: theme.cornerRadiusSmall, style: .continuous))
        .shadow(color: theme.shadowLight, radius: 4, y: 2)
        .overlay(
            RoundedRectangle(cornerRadius: theme.cornerRadiusSmall)
                .stroke(isInvalid ? Color.red.opacity(0.8) : .clear, lineWidth: 1.2)
        )

        // 👇 Game-style floating badge
        .overlay(alignment: .topTrailing) {
            if isInvalid, let errorText {
                Text(errorText)
                    .font(.caption2.bold())
                    .padding(6)
                    .background(Color.red.opacity(0.9))
                    .foregroundColor(.white)
                    .cornerRadius(6)
                    .offset(y: -28)
                    .transition(.opacity.combined(with: .scale))
                    .shadow(radius: 4)
            }
        }
        .animation(.spring(duration: 0.25), value: isInvalid)
    }
}

#Preview {
    VStack(spacing: 20) {
        TextFieldWithIcon(
            systemImage: "person.fill",
            placeholder: "Username",
            text: .constant(""),
            isInvalid: true,
            errorText: "Too short!"
        )

        TextFieldWithIcon(
            systemImage: "lock.fill",
            placeholder: "Password",
            text: .constant(""),
            isSecure: true
        )
    }
    .padding()
    .environment(\.theme, .orange)
}
