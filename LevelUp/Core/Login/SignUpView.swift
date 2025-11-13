import SwiftUI
import SwiftData

struct SignUpView: View {
    @Environment(\.theme) private var theme
    @EnvironmentObject private var userStore: UserStore

    // MARK: - User Inputs
    @State private var username: String = ""
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    @State private var agree: Bool = true

    // MARK: - Validation & UI State
    @State private var errorMessage: String?
    @State private var showPasswordRequirements = false
    @State private var isLoading = false
    @FocusState private var isConfirmFocused: Bool

    // MARK: - Computed Validations
    private var isUsernameValid: Bool {
        username.trimmingCharacters(in: .whitespacesAndNewlines).count >= 3
    }

    private var isEmailValid: Bool {
        let regex = try! NSRegularExpression(
            pattern: "^[A-Z0-9._%+-]+@[A-Z0-9.-]+\\.[A-Z]{2,}$",
            options: .caseInsensitive
        )
        return regex.firstMatch(in: email, range: NSRange(email.startIndex..., in: email)) != nil
    }

    private var isPasswordValid: Bool {
        userStore.isPasswordValid(password)
    }

    private var doPasswordsMatch: Bool {
        !confirmPassword.isEmpty && confirmPassword == password
    }

    private var isFormValid: Bool {
        isUsernameValid && isEmailValid && isPasswordValid && doPasswordsMatch && agree
    }

    // MARK: - Body
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            // USERNAME
            TextFieldWithIcon(
                systemImage: "person.fill",
                placeholder: "Username",
                text: $username,
                isInvalid: !isUsernameValid && !username.isEmpty,
                errorText: "Too short!"
            )

            // EMAIL
            TextFieldWithIcon(
                systemImage: "envelope.fill",
                placeholder: "Email",
                text: $email,
                isInvalid: !isEmailValid && !email.isEmpty,
                errorText: "Invalid email!"
            )

            // PASSWORD
            TextFieldWithIcon(
                systemImage: "lock.fill",
                placeholder: "Password",
                text: $password,
                isSecure: true,
                isInvalid: !isPasswordValid && !password.isEmpty,
                errorText: "Weak password!"
            )
            .onTapGesture {
                withAnimation(.easeInOut) { showPasswordRequirements.toggle() }
            }
            // 👇 Reset confirmation when password changes
            .onChange(of: password) { oldValue, newValue in
                if oldValue != newValue {
                    confirmPassword = ""
                    withAnimation {
                        showPasswordRequirements = true
                    }
                }
            }

            // PASSWORD REQUIREMENTS
            if showPasswordRequirements {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Password must include:")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Label("At least 8 characters", systemImage: "checkmark.circle")
                    Label("1 uppercase and 1 lowercase letter", systemImage: "checkmark.circle")
                    Label("1 number", systemImage: "checkmark.circle")
                }
                .font(.caption2)
                .foregroundStyle(.secondary)
                .transition(.opacity)
            }

            // 👇 CONDITIONAL CONFIRM PASSWORD FIELD OR FEEDBACK
            if password.count > 1 && !doPasswordsMatch {
                TextFieldWithIcon(
                    systemImage: "lock.rotation.open",
                    placeholder: "Confirm Password",
                    text: $confirmPassword,
                    isSecure: true,
                    isInvalid: !doPasswordsMatch && !confirmPassword.isEmpty,
                    errorText: "Doesn't match!"
                )
                .focused($isConfirmFocused)
                .transition(.opacity.combined(with: .move(edge: .bottom)))
                .onChange(of: confirmPassword) { _, _ in
                    if showPasswordRequirements {
                        withAnimation(.easeInOut) { showPasswordRequirements = false }
                    }
                }
            } else if doPasswordsMatch {
                // ✅ FEEDBACK STATE
                HStack(spacing: 8) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                        .font(.system(size: 18, weight: .semibold))
                    Text("Password confirmed")
                        .font(.footnote.bold())
                        .foregroundColor(.green)
                }
                .transition(.scale.combined(with: .opacity))
                .onAppear {
                    UIImpactFeedbackGenerator(style: .soft).impactOccurred()
                }
            }

            // TERMS
            Toggle(isOn: $agree) {
                Text("I agree to the Terms & Privacy")
                    .font(.footnote)
            }
            .tint(theme.primary)
            .padding(.top, 2)

            // GLOBAL ERROR BANNER
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

            // CREATE ACCOUNT BUTTON
            PrimaryButton(title: isLoading ? "Creating..." : "Create Account") {
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                Task { await createAccount() }
            }
            .disabled(!isFormValid || isLoading)
            .opacity(isFormValid ? 1 : 0.6)
            .padding(.top, 8)
        }
        .padding(16)
        .padding([.top, .bottom], 30)
        .elevatedCard(corner: theme.cornerRadiusLarge)
        .animation(.easeInOut(duration: 0.25), value: errorMessage)
        .animation(.spring(response: 0.4, dampingFraction: 0.7), value: doPasswordsMatch)
    }

    // MARK: - Actions
    private func createAccount() async {
        username = username.trimmingCharacters(in: .whitespacesAndNewlines)
        email = email.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)

        guard isFormValid else {
            errorMessage = "Fix the fields marked in red."
            return
        }

        isLoading = true
        defer { isLoading = false }

        do {
            try await userStore.signUp(username: username, email: email, password: password)
            errorMessage = nil
            print("🆕 User created successfully: \(userStore.user?.username ?? "Unknown")")
        } catch {
            if let userError = error as? UserController.UserError {
                errorMessage = userError.localizedDescription
            } else {
                errorMessage = "Something went wrong. Please try again."
            }
        }
    }
}

#Preview {
    SignUpView()
        .environment(\.theme, .orange)
        .environmentObject(UserStore())
}
