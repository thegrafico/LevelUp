//
//  FriendPreviewCardStatsOverview.swift
//  LevelUp
//
//  Created by Raúl Pichardo Avalo on 10/21/25.
//

import SwiftUI

struct FriendPreviewCardStatsOverview: View {
    @Environment(\.theme) private var theme
    
    var stats: UserStats
    
    init(_ stats: UserStats) {
        self.stats = stats
    }
    
    var body: some View {
        VStack(spacing: 10) {
            statRow(icon: "flame.fill", title: "Challenges Won", value: "\(stats.challengeWonCount)")
            statRow(icon: "bolt.fill", title: "Top Mission", value: "\(stats.topMission ?? "None")")
            statRow(icon: "clock.fill", title: "Last Active", value: "2 hours ago")
        }
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
    FriendPreviewCardStatsOverview(UserStats())
}
