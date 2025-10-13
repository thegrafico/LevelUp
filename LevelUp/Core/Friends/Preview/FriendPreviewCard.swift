//
//  FriendsPreviewCard.swift
//  LevelUp
//
//  Created by Raúl Pichardo Avalo on 10/11/25.
//

import SwiftUI

struct FriendPreviewCard: View {
    @Environment(\.theme) private var theme
    @Environment(\.dismiss) private var dismiss

    var friend: Friend
    var actionTitle: String = "Send Request Back"  // 👈 default title
    var onAction: ((Friend) -> Void)? = nil        // 👈 callback with friend info

    var body: some View {
        VStack(spacing: 16) {
            Circle()
                .fill(theme.primary.opacity(0.15))
                .frame(width: 100, height: 100)
                .overlay(
                    Image(systemName: friend.avatar)
                        .font(.system(size: 50, weight: .bold))
                        .foregroundStyle(theme.primary)
                )

            Text("@\(friend.username)")
                .font(.title2.weight(.bold))
                .foregroundStyle(theme.textPrimary)

            HStack {
                Text("Level \(friend.stats.level)")
                    .font(.subheadline)
                    .foregroundStyle(theme.textSecondary)

                if friend.stats.bestStreakCount > 0 {
                    Text("• Best Streak: \(friend.stats.bestStreakCount) days")
                        .font(.subheadline)
                        .foregroundStyle(theme.textSecondary)
                }
            }

            Divider().padding(.vertical, 8)

            VStack(spacing: 10) {
                statRow(icon: "flame.fill", title: "Challenges Won", value: "\(friend.stats.challengeWonCount)")
                statRow(icon: "bolt.fill", title: "Top Mission", value: "\(friend.stats.topMission ?? "None")")
                statRow(icon: "clock.fill", title: "Last Active", value: "2 hours ago")
            }

            Spacer()

            Button {
                onAction?(friend) // 👈 trigger callback
            } label: {
                Text(actionTitle) // 👈 dynamic title
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(theme.textInverse)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(RoundedRectangle(cornerRadius: theme.cornerRadiusLarge).fill(theme.primary))
            }
        }
        .padding(20)
        .background(theme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: theme.cornerRadiusLarge))
        .shadow(color: theme.shadowLight, radius: 10, y: 4)
        .presentationBackground(theme.background)
    }

    @ViewBuilder
    private func statRow(icon: String, title: String, value: String) -> some View {
        HStack {
            Image(systemName: icon)
                .foregroundStyle(theme.primary)
            Text(title)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(theme.textPrimary)
            Spacer()
            Text(value)
                .font(.subheadline)
                .foregroundStyle(theme.textSecondary)
        }
    }
}

#Preview {
    FriendPreviewCard(
        friend: Friend(
            username: "Thegrafico",
            stats: UserStats(level: 20, bestStreakCount: 10, topMission: "Drink Water", challengeWonCount: 4)
        )
    )
}
