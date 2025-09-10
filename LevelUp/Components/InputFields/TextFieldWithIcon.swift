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
    @State private var reveal = false
    
    var body: some View {
        HStack(spacing: 10) {
            ZStack {
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(theme.primary.opacity(0.12))
                    .frame(width: 36, height: 36)
                Image(systemName: systemImage)
                    .foregroundStyle(theme.primary)
                    .font(.system(size: 16, weight: .semibold))
            }
            if isSecure && !reveal {
                SecureField(placeholder, text: $text)
                    .textContentType(.password)
            } else {
                TextField(placeholder, text: $text)
                    .textInputAutocapitalization(.never)
                    .textContentType(isSecure ? .password : .username)
                    .autocorrectionDisabled(true)
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
    }
}


#Preview {
    TextFieldWithIcon(systemImage: "plus", placeholder: "Name", text: .constant(""))
}
