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
    @EnvironmentObject private var notificationManager: NotificationManager
    @EnvironmentObject private var modalManager: ModalManager
    
    @State private var showResetAlert = false
    @State private var showSignOutAlert = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                
                // MARK: Header
                AppTopBanner(title: "Settings", subtitle: "Customize your experience")
                
                ScrollView {
                    
                    VStack(spacing: 20) {
                        
                        // MARK: Account
                        SettingsSection(title: "Account") {
                            
                            NavigationLink {
                                ProfileView()
                            } label: {
                                SettingsRow(icon: "person.crop.circle", title: "Profile")                            }
                            
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
                            
                        // MARK: NOTIFICATIONS
                        SettingsSection(title: "Notifications") {
                            
                            ToggleRow(
                                icon: "bell.fill",
                                title: "Allow Reminders",
                                isOn: Binding(
                                    get: { notificationManager.permissionGranted },
                                    set: { newValue in
                                        if newValue {
                                            Task { await notificationManager.requestAuthorization() }
                                        } else {
                                            notificationManager.cancelAll()
                                            notificationManager.updatePermissionGranded(false)
                                        }
                                    }
                                )
                            )
                            .task {
                                await notificationManager.refreshAuthorizationStatus()
                            }
                        }
                        
                        // MARK: APPEARANCE
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
                            NavigationLink {
                                AboutView()
                            } label: {
                                SettingsRow(icon: "info.circle.fill", title: "About")
                            }
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
    .environmentObject(NotificationManager())
    
}
