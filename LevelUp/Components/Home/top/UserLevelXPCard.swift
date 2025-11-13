//
//  UserLevelXPCard.swift
//  LevelUp
//
//  Created by Raúl Pichardo Avalo on 9/6/25.
//

import SwiftUI

struct UserLevelXPCard: View {
    @Environment(\.theme) private var theme
    @Environment(BadgeManager.self) private var badgeManager: BadgeManager?

    @Bindable var stats: UserStats
    
    var onTap: () async throws -> Void
    
    var notificationsAvailable: Bool {
        badgeManager?.count(for: .userAchievementProfile) ?? 0 > 0
    }

    var body: some View {
        Button {
            Task {
                UIImpactFeedbackGenerator(style: .soft).impactOccurred()
                badgeManager?.clear(.userAchievementProfile)
                try await onTap()
            }
            
        } label: {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    VStack(alignment: .leading, spacing: 0) {
                        HStack (spacing: 0) {
                            Text("Lv. \(stats.level)")
                                .font(.title3.weight(.bold))
                                .foregroundStyle(theme.textPrimary)
                                .monospaced()
                            
                            Spacer()
                            
                            // MARK: - Notifications badge
                            // MARK: - Notifications badge
                            Image(systemName: "bell.badge.fill")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundStyle(theme.primary)
                                .background(
                                    Circle()
                                        .fill(theme.textInverse.opacity(0.1))
                                )
                                // Scale and opacity animation
                                .scaleEffect(notificationsAvailable ? 1.2 : 0.5) // scale up when appears
                                .opacity(notificationsAvailable ? 1 : 0)
                                .animation(.spring(response: 0.4, dampingFraction: 0.5), value: notificationsAvailable)
                        }
                        
                        HStack(spacing: 0) {
                            AnimatedNumberText(value: stats.xp, font: theme.bodyFont)
                                .foregroundStyle(theme.textSecondary)
                            Text(" / ")
                                .font(theme.bodyFont)
                                .foregroundStyle(theme.textSecondary)
                                .monospaced()
                            AnimatedNumberText(value: stats.requiredXP(), font: theme.bodyFont)
                                .foregroundStyle(theme.textSecondary)
                            Text(" XP")
                                .font(theme.bodyFont)
                                .foregroundStyle(theme.textSecondary)
                                .monospaced()
                            
                        }
                    }
                    Spacer()
                }
                
                ProgressView(
                    value: min(max(Double(stats.xp), 0), Double(stats.requiredXP())) ,
                    total: Double(stats.requiredXP()) ) {
                        EmptyView()
                    }
                    .progressViewStyle(ThickLinearProgressStyle(height: 22))
                    .animation(.easeOut(duration: 0.6), value: stats.xp)

            }
            .padding(20)
            .contentShape(
                RoundedRectangle(
                    cornerRadius: theme.cornerRadiusLarge,
                    style: .continuous)
            )
        }
        .buttonStyle(PressableCardStyleThemed())   // ← themed press style
        .elevatedCard()                            // ← themed card background + shadows + radius
        .padding(.horizontal, 20)
        .padding(.top, 8)
    }
}

struct PressableCardStyleThemed: ButtonStyle {
    @Environment(\.theme) private var theme
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .shadow(color: configuration.isPressed ? theme.shadowLight : theme.shadowDark,
                    radius: configuration.isPressed ? 10 : 22,
                    y: configuration.isPressed ? 8 : 16)
            .animation(.spring(duration: 0.25, bounce: 0.25), value: configuration.isPressed)
    }
}

struct AnimatedNumberText: View {
    var value: Int
    var font: Font = .body
    var style: Font.TextStyle? = nil
    
    @State private var displayedValue: Int = 0
    
    var body: some View {
        Text("\(displayedValue)")
            .font(font)
            .monospaced()
            .onChange(of: value) { old, new in
                withAnimation(.easeOut(duration: 0.6)) {
                    displayedValue = new
                }
            }
            .onAppear {
                displayedValue = value
            }
    }
}


#Preview {
    UserLevelXPCard(stats: UserStats(), onTap: {} )
        .environment(BadgeManager(defaultCount: 02))

}
