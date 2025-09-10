//
//  Leaderbaord.swift
//  LevelUp
//
//  Created by Raúl Pichardo Avalo on 9/8/25.
//

import SwiftUI

// MARK: - UI Model (solo para la vista)
struct UIRanker: Identifiable {
    let id = UUID()
    var rank: Int
    var name: String
    var xp: Int
    var avatar: String // SF Symbol
    var isMe: Bool = false
}

// Demo data
let demoRankers: [UIRanker] = [
    .init(rank: 1, name: "Ava",   xp: 1320, avatar: "person.fill"),
    .init(rank: 2, name: "Liam",  xp: 1180, avatar: "person.crop.circle.fill"),
    .init(rank: 3, name: "Maya",  xp: 1120, avatar: "person.circle.fill"),
    .init(rank: 4, name: "Noah",  xp: 980,  avatar: "person.fill"),
    .init(rank: 5, name: "Emma",  xp: 910,  avatar: "person.fill"),
    .init(rank: 6, name: "Oliver",xp: 870,  avatar: "person.fill"),
    .init(rank: 7, name: "Sofia", xp: 820,  avatar: "person.fill", isMe: true),
    .init(rank: 8, name: "Lucas", xp: 760,  avatar: "person.fill"),
]

// MARK: - Leaderboard View
struct LeaderboardView: View {
    @Environment(\.theme) private var theme

    @State private var selectedLeague: LeagueType = .none
    @State private var selectedPeriod: LeagueTimePeriod = .currentWeek
    
    var body: some View {
        
        ZStack(alignment: .top) {
            
            // Top banner reutilizando tu background
            TopBannerBackground(height: 200, radius: 0)
                .ignoresSafeArea(edges: .top)
            
            VStack(alignment: .leading, spacing: 4) {
                
                Text("LEADERBOARD")
                    .font(.system(size: 34, weight: .black, design: .rounded))
                    .kerning(1.5)
                    .foregroundStyle(theme.textInverse)
                
                Text("Season ends in 3d 11h")
                    .font(.headline) // bigger than footnote
                    .foregroundStyle(theme.textInverse.opacity(0.8))
                    .padding(.bottom, 30)
                
                Group {
                    
                    LeagueControls(
                        selectedPeriod: $selectedPeriod,
                        selectedLeague: $selectedLeague)
                    
                    
                    // TODO: If users < 3 show another view
                    // MARK: TOP 3 Players
                    PodiumTopPlayers(rankers: Array(demoRankers.prefix(3)))
                    
                    // MARK: List of users in ranking
                    LeaderboardRankingList(usersRanking: Array(demoRankers.dropFirst(3)))
                    
                }
                .padding(.top, 10)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 12)
            .padding(.top, 50)
            .scrollIndicators(.hidden)
        }
    }
}


#Preview {
    NavigationStack {
        LeaderboardView()
    }
    .environment(\.theme, .orange)
}
