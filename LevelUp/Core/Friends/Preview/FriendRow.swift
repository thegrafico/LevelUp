//
//  FriendRow.swift
//  LevelUp
//
//  Created by Raúl Pichardo Avalo on 10/11/25.
//

import SwiftUI

struct FriendRow: View {
    @Environment(\.theme) private var theme
    var friend: Friend
    
    var onPress: ((Friend) -> Void)? = nil
    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: theme.cornerRadiusSmall, style: .continuous)
                    .fill(friend.stats.isOnline ? theme.primary.opacity(0.18) : theme.textPrimary.opacity(0.08))
                    .frame(width: 48, height: 48)
                Image(systemName: friend.avatar)
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundStyle(friend.stats.isOnline ? theme.primary : theme.textSecondary)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 6) {
                    Text(friend.username)
                        .font(.headline.weight(.semibold))
                        .foregroundStyle(theme.textPrimary)
                    
                    if friend.stats.isOnline {
                        Circle().fill(theme.primary).frame(width: 6, height: 6)
                    }
                }
                Text("level: \(friend.stats.level)")
                    .font(.subheadline)
                    .foregroundStyle(theme.textSecondary)
            }
            Spacer()
            
            Button {
                onPress?(friend)
            } label: {
                Text("Challenge")
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(theme.primary)
                    .padding(.horizontal, 10).padding(.vertical, 8)
                    .background(Capsule().fill(theme.primary.opacity(0.1)))
            }
            .buttonStyle(.plain)
        }
        .padding(12)
        .background(theme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: theme.cornerRadiusLarge, style: .continuous))
        .shadow(color: theme.shadowLight, radius: 6, y: 3)
    }
}

#Preview {
    FriendRow(friend: .init(username: "Thegrafico", stats: .init(level: 20, bestStreakCount: 10, topMission: "Drink Water", challengeWonCount: 20)))
}
