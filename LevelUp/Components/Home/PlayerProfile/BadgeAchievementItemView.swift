//
//  BadgeAchievementItemView.swift
//  LevelUp
//
//  Created by Raúl Pichardo Avalo on 11/11/25.
//

import SwiftUI

struct BadgeAchievementItemView: View {
    @Environment(\.theme) private var theme
    
    let badge: BadgeAchievement
    let isUnlocked: Bool

    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: badge.icon)
                .font(.largeTitle)
                .foregroundStyle(isUnlocked ? badge.color : .gray.opacity(0.5))
                .saturation(isUnlocked ? 1 : 0)
                .brightness(isUnlocked ? 0 : 0.3)
                .overlay(
                    Group {
                        if !isUnlocked {
                            Image(systemName: "lock.fill")
                                .font(.caption2)
                                .offset(x: 14, y: -14)
                                .foregroundStyle(.gray.opacity(0.7))
                        }
                    }
                )

            Text(badge.title)
                .font(.caption.bold())
                .foregroundStyle(isUnlocked ? theme.textPrimary : theme.textSecondary.opacity(0.7))
        }
        .frame(maxHeight: 80)
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(isUnlocked ? badge.color.opacity(0.1) : Color.gray.opacity(0.1))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isUnlocked ? badge.color.opacity(0.3) : .gray.opacity(0.1), lineWidth: 1)
        )
        .shadow(color: isUnlocked ? badge.color.opacity(0.2) : .clear, radius: 3, y: 2)
        .animation(.easeInOut(duration: 0.3), value: isUnlocked)
        
    }
}

#Preview {
    BadgeAchievementItemView(badge: Achievement.ALL_BADGE_ACHIEVEMENTS.first!, isUnlocked: true)
}
