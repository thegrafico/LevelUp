import SwiftUI
import SwiftData


struct LoginView: View {
    @Environment(\.theme) private var theme
    @EnvironmentObject private var userStore: UserStore

    // MARK: - User Inputs
    @State private var identifier: String = "" // username OR email
    @State private var password: String = ""
    @State private var rememberMe: Bool = true

    // MARK: - UI & Validation
    @State private var isLoading = false
    @State private var errorMessage: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            // Identifier (username or email)
            TextFieldWithIcon(
                systemImage: "person.fill",
                placeholder: "Username or Email",
                text: $identifier
            )
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled(true)
            .onChange(of: identifier) { _, _ in
                if errorMessage != nil { errorMessage = nil } // 👈 Clear error when typing again
            }

            // Password
            TextFieldWithIcon(
                systemImage: "lock.fill",
                placeholder: "Password",
                text: $password,
                isSecure: true
            )
            .onChange(of: password) { _, _ in
                if errorMessage != nil { errorMessage = nil } // 👈 Clear error when typing again
            }

            // Remember + Forgot
            HStack {
                Toggle("Remember me", isOn: $rememberMe)
                    .font(.footnote)
                    .tint(theme.primary)
                Spacer()
                Button("Forgot password?") { /* TODO: implement later */ }
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(theme.primary)
            }
            .padding(.top, 4)

            // Error banner
            if let errorMessage {
                HStack {
                    Image(systemName: "exclamationmark.triangle.fill")
                    Text(errorMessage)
                        .font(.footnote.bold())
                }
                .padding(10)
                .frame(maxWidth: .infinity)
                .background(.red.opacity(0.9))
                .cornerRadius(8)
                .foregroundColor(.white)
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }

            // Login button
            PrimaryButton(title: isLoading ? "Logging In..." : "Log In") {
                UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
                Task { await loginUser() }
            }
            .disabled(isLoading || identifier.isEmpty || password.isEmpty)
            .opacity(isLoading || identifier.isEmpty || password.isEmpty ? 0.6 : 1)
            .padding(.top, 6)
        }
        .padding(16)
        .padding([.top, .bottom], 30)
        .elevatedCard(corner: theme.cornerRadiusLarge)
        .animation(.easeInOut(duration: 0.25), value: errorMessage)
    }

    // MARK: - Actions
    @MainActor
    private func loginUser() async {
        errorMessage = nil
        isLoading = true

        do {
            try await userStore.login(
                identifier: identifier.trimmingCharacters(in: .whitespacesAndNewlines),
                password: password.trimmingCharacters(in: .whitespacesAndNewlines)
            )

            print("🎮 User logged in successfully: \(userStore.user?.username ?? "unknown")")

        } catch {
            errorMessage = (error as? LocalizedError)?.errorDescription
                ?? "Invalid username/email or password."
            print("❌ Login failed:", error)
        }

        isLoading = false
    }
}

#Preview {
    LoginView()
        .environment(\.theme, .orange)
        .environmentObject(UserStore())
}
