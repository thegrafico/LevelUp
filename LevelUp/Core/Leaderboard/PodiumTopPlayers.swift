//
//  TopPlayersBanner.swift
//  LevelUp
//
//  Created by Raúl Pichardo Avalo on 9/9/25.
//

import SwiftUI

struct PodiumTopPlayers: View {
    @Environment(\.theme) private var theme
    let rankers: [UIRanker] // expects 3
    
    var body: some View {
        HStack(alignment: .bottom, spacing: 12) {
            PodiumTile(r: rankers[safe: 0], place: 1)  // 1st (más alto)
                .frame(maxWidth: .infinity)
            
            PodiumTile(r: rankers[safe: 1], place: 2)  // 2nd
                .frame(maxWidth: .infinity)
            
            PodiumTile(r: rankers[safe: 2], place: 3)  // 3rd
                .frame(maxWidth: .infinity)
        }
        .padding(12)
        .background(theme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: theme.cornerRadiusLarge, style: .continuous))
        .shadow(color: theme.shadowLight, radius: 8, y: 4)
        .shadow(color: theme.shadowDark, radius: 16, y: 10)
    }
}

struct PodiumTile: View {
    @Environment(\.theme) private var theme
    let r: UIRanker?
    let place: Int
    
    var body: some View {
        VStack(spacing: 8) {
            if let r {
                ZStack {
                    Circle()
                        .fill(theme.primary.opacity(0.12))
                        .frame(width: place == 1 ? 70 : 58, height: place == 1 ? 70 : 58)
                    
                    Image(systemName: r.avatar)
                        .font(.system(size: place == 1 ? 28 : 24, weight: .semibold))
                        .foregroundStyle(theme.primary)
                }
                
                HStack(spacing: 6) {
                    
                    // MARK: TOP 3 Crown color
                    Image(systemName: "crown.fill").foregroundStyle(
                        place == 1 ? theme.accent : place == 2 ? .gray : .brown
                    )
                    
                    Text("\(r.rank)")
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(place == 1 ? theme.primary : theme.textSecondary)
                }
                
                Text(r.name)
                    .font(.subheadline.weight(.semibold))
                    .lineLimit(1)
                    .foregroundStyle(theme.textPrimary)
                
                Text("\(r.xp) XP")
                    .font(.footnote).monospaced()
                    .foregroundStyle(theme.primary)
            } else {
                // placeholder tile
                RoundedRectangle(cornerRadius: theme.cornerRadiusSmall)
                    .fill(theme.textPrimary.opacity(0.05))
            }
        }
        .padding(.vertical, place == 1 ? 12 : 8)
        .padding(.horizontal, 8)
        .background(
            RoundedRectangle(cornerRadius: theme.cornerRadiusSmall, style: .continuous)
                .fill(theme.cardBackground)
        )
        .overlay(
            RoundedRectangle(cornerRadius: theme.cornerRadiusSmall, style: .continuous)
                .stroke(theme.textPrimary.opacity(0.06), lineWidth: 1)
        )
        .shadow(color: theme.shadowLight, radius: place == 1 ? 8 : 4, y: place == 1 ? 6 : 3)
    }
}


#Preview {
    PodiumTopPlayers(rankers: Array(demoRankers.prefix(3)))
}
