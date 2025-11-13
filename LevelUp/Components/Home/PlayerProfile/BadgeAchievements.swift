//
//  BadgeAchievements.swift
//  LevelUp
//
//  Created by Raúl Pichardo Avalo on 11/10/25.
//

import SwiftUI

struct BadgeAchievementsView: View {
    @Environment(\.theme) private var theme
    @Environment(\.currentUser) private var user
    @Environment(BadgeManager.self) private var badgeManager: BadgeManager?

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Achievements")
                .font(.headline)
                .foregroundStyle(theme.textSecondary)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(sortedBadges, id: \.id) { badge in
                        let isUnlocked = user.achievements.contains {
                            $0.id == badge.id || $0.title == badge.title
                        }

                        BadgeAchievementItemView(badge: badge, isUnlocked: isUnlocked)
                            .overlay(alignment: .topTrailing) {
                                badgeManager?.badgeView(for: .userAchievement(badge.title),
                                                        size: 15,
                                                        offsetX: 2,
                                                        offsetY: 2)
                            }.onTapGesture {
                                // MARK: - Update user badget to be read
                                badgeManager?.clear(.userAchievement(badge.title))
                            }
                            .tapBounce()
                    }
                }
                .padding(.horizontal)
            }
        }
    }

    // MARK: - Computed Sorted Array
    private var sortedBadges: [BadgeAchievement] {
        Achievement.ALL_BADGE_ACHIEVEMENTS.sorted { a, b in
            let aUnlocked = user.achievements.contains { $0.id == a.id || $0.title == a.title }
            let bUnlocked = user.achievements.contains { $0.id == b.id || $0.title == b.title }

            // unlocked ones go first
            if aUnlocked && !bUnlocked { return true }
            if !aUnlocked && bUnlocked { return false }

            // fallback: alphabetical or static order
            return false
        }
    }
}

#Preview {
    BadgeAchievementsView()
        .environment(\.currentUser, User.sampleUserWithLogs())
        .environment(BadgeManager(defaultCount: 1))
        .padding(20)
}
