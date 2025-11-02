//
//  ProfileView.swift
//  LevelUp
//
//  Created by Raúl Pichardo Avalo on 11/1/25.
//

import SwiftUI
import SwiftData

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

    // MARK: - UI State
    @State private var errorMessage: String?
    @State private var successMessage: String?
    @State private var isLoading = false

    // MARK: - Validation
    private var isFormValid: Bool {
        !username.trimmingCharacters(in: .whitespaces).isEmpty &&
        !currentPassword.isEmpty &&
        !newPassword.isEmpty &&
        newPassword == confirmPassword
    }

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
                    
                    Text(username)
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
                    isSecure: true
                )

                TextFieldWithIcon(
                    systemImage: "lock.rotation.open",
                    placeholder: "Confirm New Password",
                    text: $confirmPassword,
                    isSecure: true,
                    isInvalid: !confirmPassword.isEmpty && confirmPassword != newPassword,
                    errorText: "Passwords don’t match"
                )

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
                .disabled(!isFormValid || isLoading)
                .opacity(isFormValid ? 1 : 0.6)
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

    // MARK: - Actions
    @MainActor
    private func saveProfile() async {
        isLoading = true
        errorMessage = nil
        successMessage = nil

        // Verify current password
        guard currentPassword == user.passwordHash else {
            errorMessage = "Current password is incorrect."
            isLoading = false
            return
        }

        // Update user data
        user.username = username
        user.passwordHash = newPassword

        do {
            try context.save()
            successMessage = "Profile updated successfully!"
            print("✅ Profile updated for \(user.username)")
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                dismiss()
            }
        } catch {
            print("❌ Error saving profile: \(error)")
            errorMessage = "Failed to save profile."
        }

        isLoading = false
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
