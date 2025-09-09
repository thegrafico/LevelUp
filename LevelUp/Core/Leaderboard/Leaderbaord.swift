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
private let demoRankers: [UIRanker] = [
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
    @State private var selectedLeague = 0
    @State private var selectedPeriod = 0
    
    private let leagues = ["Bronze", "Silver", "Gold"]
    private let periods = ["This Week", "Last Week"]
    
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
                
                Group {
                    // Controles de liga / periodo
                    LeagueControls(selectedLeague: $selectedLeague,
                                   leagues: leagues,
                                   selectedPeriod: $selectedPeriod,
                                   periods: periods)
                    .padding(.top, 30)
                    
                    
                    PodiumView(rankers: Array(demoRankers.prefix(3)))
                    
                    // Progreso semanal (del usuario)
                    TodayProgressCard(current: 420, goal: 700)
                    
                    ScrollView {
                        VStack(spacing: 16) {
                            
                            // Título y subtítulo
                            
                            // Lista de posiciones (del 4 en adelante)
                            VStack(spacing: 10) {
                                ForEach(demoRankers.dropFirst(3)) { r in
                                    LeaderRow(r: r)
                                    
                                }
                            }
                            .padding(.bottom, 24)
                        }
                        .padding(.horizontal, 20)
                    }
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

// MARK: - League Controls (chips)
struct LeagueControls: View {
    @Environment(\.theme) private var theme
    @Binding var selectedLeague: Int
    let leagues: [String]
    
    @Binding var selectedPeriod: Int
    let periods: [String]
    
    var body: some View {
        VStack {
            
            // Periodo (segmented-like)
            HStack(spacing: 8) {
                ForEach(periods.indices, id: \.self) { i in
                    let isSel = selectedPeriod == i
                    Text(periods[i])
                        .font(.footnote.weight(.semibold))
                        .foregroundStyle(isSel ? theme.textInverse : theme.textPrimary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: theme.cornerRadiusSmall, style: .continuous)
                                .fill(isSel ? theme.primary : theme.cardBackground)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: theme.cornerRadiusSmall, style: .continuous)
                                .stroke(theme.textPrimary.opacity(0.08), lineWidth: isSel ? 0 : 1)
                        )
                        .onTapGesture { selectedPeriod = i }
                }
            }
            .elevatedCard(corner: theme.cornerRadiusLarge)
        }
    }
}

// MARK: - Podium Top 3
struct PodiumView: View {
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

// MARK: - Weekly Progress (card compacta)
struct TodayProgressCard: View {
    @Environment(\.theme) private var theme
    var current: Int
    var goal: Int
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("My Weekly XP")
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(theme.textPrimary)
                Spacer()
                Text("\(current) / \(goal)")
                    .font(.footnote).monospaced()
                    .foregroundStyle(theme.textSecondary)
            }
            ProgressView(value: Double(current), total: Double(goal)) { EmptyView() }
                .progressViewStyle(ThickLinearProgressStyle(height: 12))
        }
        .padding(16)
        .background(theme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: theme.cornerRadiusLarge, style: .continuous))
        .shadow(color: theme.shadowLight, radius: 8, y: 4)
        .shadow(color: theme.shadowDark, radius: 16, y: 10)
    }
}

// MARK: - Rank Row
struct LeaderRow: View {
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

// MARK: - Helpers
private extension Collection {
    subscript(safe index: Index) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}

#Preview {
    NavigationStack {
        LeaderboardView()
    }
    .environment(\.theme, .orange)
}
