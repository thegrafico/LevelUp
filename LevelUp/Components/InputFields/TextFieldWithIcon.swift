import SwiftUI

struct TextFieldWithIcon: View {
    @Environment(\.theme) private var theme
    @Environment(\.colorScheme) private var colorScheme

    var systemImage: String
    var placeholder: String
    @Binding var text: String
    var isSecure: Bool = false

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

            // MARK: TextField / SecureField
            Group {
                if isSecure && !reveal {
                    SecureField("", text: $text, prompt: Text(placeholder)
                        .foregroundColor(placeholderColor))
                        .textContentType(.password)
                        .foregroundColor(isInvalid ? .red : theme.textPrimary)
                } else {
                    TextField("", text: $text, prompt: Text(placeholder)
                        .foregroundColor(placeholderColor))
                        .textInputAutocapitalization(.never)
                        .textContentType(isSecure ? .password : .username)
                        .autocorrectionDisabled(true)
                        .foregroundColor(isInvalid ? .red : theme.textPrimary)
                }
            }

            // MARK: Eye toggle for secure field
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

    // MARK: - Dynamic placeholder color
    private var placeholderColor: Color {
        if colorScheme == .dark {
            return theme.textSecondary.opacity(0.7)
        } else {
            return theme.textSecondary.opacity(0.9)
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        TextFieldWithIcon(
            systemImage: "person.fill",
            placeholder: "Username",
            text: .constant("")
        )

        TextFieldWithIcon(
            systemImage: "lock.fill",
            placeholder: "Password",
            text: .constant(""),
            isSecure: true
        )
    }
    .padding()
    .environment(\.theme, .dark)
}
