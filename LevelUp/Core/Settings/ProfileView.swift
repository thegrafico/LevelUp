//
//  ProfileView.swift
//  LevelUp
//
//  Created by Raúl Pichardo Avalo on 11/1/25.
//

import SwiftUI
import SwiftData

enum ProfileUpdateError: LocalizedError {
    case usernameUnavailable
    case usernameValidationFailed(String)
    case invalidCurrentPassword
    case weakNewPassword

    var errorDescription: String? {
        switch self {
        case .usernameUnavailable:
            "Username is already taken."
        case .usernameValidationFailed(let reason):
            reason
        case .invalidCurrentPassword:
            "Current password is incorrect."
        case .weakNewPassword:
            "New password is too weak."
        }
    }

    // ✅ Mapper initializer
    init(from usernameError: UsernameValidationError) {
        switch usernameError {
        case .usernameTaken:
            self = .usernameUnavailable
        default:
            self = .usernameValidationFailed(usernameError.localizedDescription)
        }
    }
}

struct ProfileView: View {
    @Environment(\.theme) private var theme
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    @Environment(\.currentUser) private var user
    @EnvironmentObject private var userStore: UserStore
    
    // MARK: - User Input
    @State private var username: String = ""
    @State private var currentPassword: String = ""
    @State private var newPassword: String = ""
    @State private var confirmPassword: String = ""
    @FocusState private var isConfirmFocused: Bool
    
    // MARK: - UI State
    @State private var errorMessage: String?
    @State private var successMessage: String?
    @State private var isLoading = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                // MARK: - Avatar
                VStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(theme.primary.opacity(0.15))
                            .frame(width: 110, height: 110)
                            .shadow(color: theme.accent.opacity(0.5), radius: 20)
                        Image(systemName: "person.fill")
                            .font(.system(size: 48, weight: .bold))
                            .foregroundStyle(theme.primary)
                    }
                    
                    Text(user.username)
                        .font(.title3.bold())
                        .foregroundStyle(theme.textPrimary)
                }
                .frame(maxWidth: .infinity)
                .padding(.bottom, 8)
                
                // MARK: - Username
                TextFieldWithIcon(
                    systemImage: "person.fill",
                    placeholder: "Username",
                    text: $username
                )
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled(true)
                
                // MARK: - Email (read-only)
                TextFieldWithIcon(
                    systemImage: "envelope.fill",
                    placeholder: "Email",
                    text: .constant(user.email)
                )
                .disabled(true)
                .opacity(0.7)
                
                // MARK: - Password Section
                Divider().padding(.vertical, 10)
                
                Text("Change Password")
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(theme.textSecondary)
                    .padding(.bottom, 4)
                
                TextFieldWithIcon(
                    systemImage: "lock.fill",
                    placeholder: "Current Password",
                    text: $currentPassword,
                    isSecure: true
                )
                
                TextFieldWithIcon(
                    systemImage: "lock.rotation",
                    placeholder: "New Password",
                    text: $newPassword,
                    isSecure: true,
                    isInvalid: !isPasswordValid && !newPassword.isEmpty,
                    errorText: "Weak password!"
                )
                .onChange(of: newPassword) { oldValue, newValue in
                    // Reset confirmation when new password changes
                    if oldValue != newValue {
                        confirmPassword = ""
                    }
                }
                
                // CONDITIONAL CONFIRM FIELD OR FEEDBACK
                if newPassword.count > 1 && !doPasswordsMatch {
                    TextFieldWithIcon(
                        systemImage: "lock.rotation.open",
                        placeholder: "Confirm New Password",
                        text: $confirmPassword,
                        isSecure: true,
                        isInvalid: !doPasswordsMatch && !confirmPassword.isEmpty,
                        errorText: "Doesn’t match!"
                    )
                    .focused($isConfirmFocused)
                    .transition(.opacity.combined(with: .move(edge: .bottom)))
                    
                } else if doPasswordsMatch && !newPassword.isEmpty {
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
                
                // MARK: - Feedback Messages
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
                    .transition(.opacity)
                }
                
                if let successMessage {
                    HStack {
                        Image(systemName: "checkmark.seal.fill")
                        Text(successMessage)
                            .font(.footnote.bold())
                    }
                    .padding(10)
                    .frame(maxWidth: .infinity)
                    .background(.green.opacity(0.9))
                    .cornerRadius(8)
                    .foregroundColor(.white)
                    .transition(.opacity)
                }
                
                // MARK: - Save Button
                PrimaryButton(title: isLoading ? "Saving..." : "Save Changes") {
                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                    Task { await saveProfile() }
                }
                .disabled(!hasChanges || isLoading)
                .opacity(hasChanges ? 1 : 0.6)
                .padding(.top, 10)
                
                // MARK: - Cancel
                Button("Cancel") {
                    dismiss()
                }
                .font(.footnote.weight(.semibold))
                .foregroundStyle(theme.textSecondary)
                .frame(maxWidth: .infinity)
                .padding(.top, 6)
            }
            .padding(16)
            .padding([.top, .bottom], 30)
            .elevatedCard(corner: theme.cornerRadiusLarge)
            .padding(.horizontal, 20)
        }
        .background(theme.background.ignoresSafeArea())
        .navigationTitle("Edit Profile")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            username = user.username
        }
    }
    
    @MainActor
    private func saveProfile() async {
        isLoading = true
        errorMessage = nil
        successMessage = nil
        
        do {
            try await updateUsername()
            
            try await updatePassword()
            
            try context.save()
        
            successMessage = "Profile updated successfully!"
            
            print("✅ Profile updated for \(user.username)")
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                dismiss()
            }
            
        } catch {
            print("❌ Error saving profile: \(error)")
            
            if let profileError = error as? ProfileUpdateError {
                errorMessage = profileError.localizedDescription
            } else {
                errorMessage = "Unexpected error: \(error.localizedDescription)"
            }
            
        }
        
        isLoading = false
    }
    
    private func updateUsername() async throws {
        if username != user.username {
            do {
                try await userStore.validateUsername(username)
                user.username = username
            } catch let usernameError as UsernameValidationError {
                throw ProfileUpdateError(from: usernameError)
            } catch {
                throw ProfileUpdateError.usernameValidationFailed("Unexpected error: \(error.localizedDescription)")
            }
        }
    }
    
    private func updatePassword() async throws {
        if !newPassword.isEmpty {
            
            guard userStore.validateUserPassword(currentPassword) else {
                throw ProfileUpdateError.invalidCurrentPassword
            }
            
            guard userStore.isPasswordValid(newPassword) else {
                throw ProfileUpdateError.weakNewPassword
            }
            
            user.passwordHash = userStore.emcrypPassword(newPassword)
        }
    }
    
    // MARK: - FORM - Validation
    private var isFormValid: Bool {
        !username.trimmingCharacters(in: .whitespaces).isEmpty
    }
    
    private var isPasswordValid: Bool {
        userStore.isPasswordValid(newPassword)
    }
    
    private var doPasswordsMatch: Bool {
        !confirmPassword.isEmpty && confirmPassword == newPassword
    }
    
    private var hasChanges: Bool {
        username != user.username || !newPassword.isEmpty
    }
    
}

#Preview {
    NavigationStack {
        ProfileView()
    }
    .environment(\.theme, .dark)
    .environment(\.currentUser, User.sampleUser())
    .environmentObject(UserStore())
}
