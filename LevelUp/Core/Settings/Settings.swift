//
//  Settings.swift
//  LevelUp
//
//  Created by Raúl Pichardo Avalo on 9/9/25.
//

import SwiftUI

struct SettingsView: View {
    @Environment(\.theme) private var theme
    @State private var notificationsOn = true
    @State private var darkModeOn = false
        
    var body: some View {
        VStack(spacing: 0) {
            
            ZStack(alignment: .top) {
                BannerHeader(title: "Settings", subtitle: "Customize your experience")
                    .ignoresSafeArea(edges: .top)
            }
            .frame(height: 140)
            
            // Scrollable content below
            ScrollView {
                VStack(spacing: 20) {
                    SettingsSection(title: "Account") {
                        SettingsRow(icon: "person.crop.circle", title: "Profile")
                        SettingsRow(icon: "arrow.right.square", title: "Sign Out")
                    }
                    
                    SettingsSection(title: "Notifications") {
                        SettingsToggleRow(icon: "bell.fill", title: "Daily Reminders", isOn: $notificationsOn)
                    }
                    
                    SettingsSection(title: "Appearance") {
                        SettingsToggleRow(icon: "moon.fill", title: "Dark Mode", isOn: $darkModeOn)
                        SettingsRow(icon: "paintpalette.fill", title: "Theme")
                    }
                    
                    SettingsSection(title: "About") {
                        SettingsRow(icon: "info.circle.fill", title: "App Version 1.0")
                        SettingsRow(icon: "envelope.fill", title: "Feedback")
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                .padding(.bottom, 40)
            }
        }
        .background(theme.background)
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
    .environment(\.theme, .orange)
}
