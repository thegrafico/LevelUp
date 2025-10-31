//
//  Settings.swift
//  LevelUp
//
//  Created by Raúl Pichardo Avalo on 9/9/25.
//

import SwiftUI

struct SettingsView: View {
    @Environment(\.theme) private var theme
    @Environment(\.modelContext) private var context
    @Environment(\.currentUser) private var user
    @EnvironmentObject private var userStore: UserStore
    
    @EnvironmentObject private var modalManager: ModalManager
    
    @State private var notificationsOn = true
    @State private var darkModeOn = false
    @State private var showResetAlert = false
    @State private var showSignOutAlert = false
    
    var body: some View {
        VStack(spacing: 20) {
            
            AppTopBanner(title: "Settings", subtitle: "Customize your experience")
            
            ScrollView {
                VStack(spacing: 20) {
                    
                    // MARK: Account
                    SettingsSection(title: "Account") {
                        SettingsRow(icon: "person.crop.circle", title: "Profile")
                        
                        Button {
                            UIImpactFeedbackGenerator(style: .soft).impactOccurred()
                            let signOutModalData = ConfirmationModalData(
                                title: "Sign Out?",
                                message: "See you back soon, \(user.username)!",
                                confirmButtonTitle: "Sign Out",
                                cancelButtonTitle: "Cancel",
                                confirmAction: {
                                    await userStore.logoutAsync()
                                },
                            )
                            modalManager.presentModal(signOutModalData)

                        } label: {
                            SettingsRow(icon: "arrow.right.square", title: "Sign Out")
                        }
                        .tint(.red)
                    }
                    
                    // MARK: Notifications
                    SettingsSection(title: "Notifications") {
                        SettingsToggleRow(icon: "bell.fill", title: "Daily Reminders", isOn: $notificationsOn)
                    }
                    
                    // MARK: Appearance
                    SettingsSection(title: "Appearance") {
                        VStack(spacing: 8) {
                            HStack {
                                IconBox(icon: "paintpalette.fill", color: theme.primary)
                                Text("Theme")
                                    .font(.body.weight(.semibold))
                                    .foregroundStyle(theme.textPrimary)
                                Spacer()
                            }
                            .padding(.horizontal, 16)
                            .padding(.top, 12)
                            
                            ThemePickerRow()
                                .padding(.bottom, 8)
                        }
                    }
                    
                    // MARK: About
                    SettingsSection(title: "About") {
                        SettingsRow(icon: "info.circle.fill", title: "App Version 1.0")
                        SettingsRow(icon: "envelope.fill", title: "Feedback")
                    }
                    
                    // MARK: Danger Zone
                    SettingsSection(title: "Danger Zone") {
                        Button {
                            let resetProgressModal = ConfirmationModalData(
                                title: "Reset Progress?",
                                message: "This will reset your level, XP, missions, and logs, but keep your account.",
                                confirmButtonTitle: "Reset",
                                cancelButtonTitle: "Cancel",
                                confirmAction: {
                                    withAnimation(.easeInOut(duration: 0.3)) {
                                        user.deleteAllData(context: context)
                                    }
                                }
                            )
                            
                            modalManager.presentModal(resetProgressModal)

                        } label: {
                            SettingsRow(icon: "arrow.counterclockwise", title: "Reset Progress")
                        }
                        .tint(.red)
                    }
                    .padding(.bottom, 100)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 40)
            }
        }
        .ignoresSafeArea()
        .background(theme.background)
        
    }
    
    struct ThemePickerRow: View {
        @AppStorage("selectedTheme") private var selectedThemeRawValue: String = ThemeOption.system.rawValue
        @Environment(\.colorScheme) private var colorScheme
        @Environment(\.theme) private var theme

        var body: some View {
            VStack(alignment: .leading, spacing: 10) {
                Picker("Theme", selection: $selectedThemeRawValue) {
                    ForEach(ThemeOption.allCases) { option in
                        HStack {
                            Circle()
                                .fill(option.resolve(using: colorScheme).primary)
                                .frame(width: 22, height: 22)
                            Text(option.displayName)
                        }
                        .tag(option.rawValue)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal, 16)
                // 👇 This forces a re-creation of the UIKit view with correct theme
                .id(theme.primary.description)
                .onAppear { updateSegmentedControlAppearance() }
                .onChange(of: theme.primary) { 
                    updateSegmentedControlAppearance()
                }
            }
        }

        private func updateSegmentedControlAppearance() {
            let appearance = UISegmentedControl.appearance()
            appearance.selectedSegmentTintColor = UIColor(theme.primary)
            appearance.backgroundColor = UIColor(theme.cardBackground)
            appearance.setTitleTextAttributes(
                [.foregroundColor: UIColor(theme.textPrimary)],
                for: .normal
            )
            appearance.setTitleTextAttributes(
                [.foregroundColor: UIColor(theme.textInverse)],
                for: .selected
            )
        }
    }
}

// MARK: - Section Container
struct SettingsSection<Content: View>: View {
    @Environment(\.theme) private var theme
    var title: String
    @ViewBuilder var content: Content
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title.uppercased())
                .font(.caption.weight(.semibold))
                .foregroundStyle(theme.textSecondary)
                .padding(.horizontal, 4)
            
            VStack(spacing: 1) {
                content
            }
            .padding(.vertical, 8)
            .background(theme.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: theme.cornerRadiusLarge, style: .continuous))
            .shadow(color: theme.shadowLight, radius: 6, y: 3)
        }
    }
}

// MARK: - Normal Row
struct SettingsRow: View {
    @Environment(\.theme) private var theme
    var icon: String
    var title: String
    
    var body: some View {
        HStack(spacing: 12) {
            IconBox(icon: icon, color: theme.primary)
            Text(title)
                .font(.body.weight(.semibold))
                .foregroundStyle(theme.textPrimary)
            Spacer()
            Image(systemName: "chevron.right")
                .font(.footnote.weight(.semibold))
                .foregroundStyle(theme.textSecondary.opacity(0.6))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
}

// MARK: - Toggle Row
struct SettingsToggleRow: View {
    @Environment(\.theme) private var theme
    var icon: String
    var title: String
    @Binding var isOn: Bool
    
    var body: some View {
        HStack(spacing: 12) {
            IconBox(icon: icon, color: theme.primary)
            Text(title)
                .font(.body.weight(.semibold))
                .foregroundStyle(theme.textPrimary)
            Spacer()
            Toggle("", isOn: $isOn)
                .labelsHidden()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
}

// MARK: - Icon Box
struct IconBox: View {
    var icon: String
    var color: Color
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(color.opacity(0.12))
                .frame(width: 36, height: 36)
            Image(systemName: icon)
                .foregroundStyle(color)
                .font(.system(size: 16, weight: .semibold))
        }
    }
}

#Preview {
    NavigationStack {
        SettingsView()
    }
    .modelContainer(SampleData.shared.modelContainer)
    .environment(\.theme, .dark)
    .environment(\.currentUser, User.sampleUser())
    .environmentObject(ModalManager())
}
