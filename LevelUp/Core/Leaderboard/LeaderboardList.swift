//
//  LeaderboardList.swift
//  LevelUp
//
//  Created by Raúl Pichardo Avalo on 9/9/25.
//

import SwiftUI

struct LeaderboardRankingList: View {
    let usersRanking: [UIRanker]
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                
                // Lista de posiciones (del 4 en adelante)
                VStack(spacing: 10) {
                    ForEach(usersRanking) { userRank in
                        leaderboardRow(r: userRank)
                    }
                }
                .padding(.bottom, 24)
            }
            .padding(.horizontal, 20)
        }
    }
}

struct leaderboardRow: View {
    @Environment(\.theme) private var theme
    var r: UIRanker
    
    var body: some View {
        HStack(spacing: 12) {
            Text("\(r.rank)")
                .font(.footnote)
                .foregroundStyle(r.isMe ? theme.primary : theme.textSecondary)
            
            ZStack {
                RoundedRectangle(cornerRadius: theme.cornerRadiusSmall, style: .continuous)
                    .fill(theme.primary.opacity(0.12))
                    .frame(width: 44, height: 44)
                Image(systemName: r.avatar)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(theme.primary)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                HStack {
                    Text(r.name)
                        .font(.headline.weight(.semibold))
                        .foregroundStyle(r.isMe ? theme.primary : theme.textPrimary)
                    if r.isMe {
                        Text("YOU").font(.caption2.weight(.black))
                            .padding(.horizontal, 6).padding(.vertical, 2)
                            .background(
                                Capsule().fill(theme.primary.opacity(0.15))
                            )
                            .foregroundStyle(theme.primary)
                    }
                }
                Text("\(r.xp) XP")
                    .font(.footnote).monospaced()
                    .foregroundStyle(theme.textSecondary)
            }
            
            Spacer()
            
            // simple “delta” badge
            HStack(spacing: 4) {
                Image(systemName: "arrow.up.right")
                Text("+40")
                    .monospaced()
            }
            .font(.footnote.weight(.semibold))
            .foregroundStyle(theme.primary)
            .padding(.horizontal, 10).padding(.vertical, 8)
            .background(Capsule().fill(theme.primary.opacity(0.1)))
        }
        .padding(12)
        .background(theme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: theme.cornerRadiusLarge, style: .continuous))
        .shadow(color: theme.shadowLight, radius: 6, y: 3)
    }
}


#Preview {
    LeaderboardRankingList(usersRanking: demoRankers)
}
