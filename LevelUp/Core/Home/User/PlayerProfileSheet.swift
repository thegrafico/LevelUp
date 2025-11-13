//
//  PlayerProfileSheet.swift
//  LevelUp
//
//  Created by Raúl Pichardo Avalo on 11/10/25.
//

import SwiftUI

struct PlayerProfileSheet: View {
    @Environment(\.theme) private var theme
    @Environment(\.currentUser) private var user
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        
        NavigationStack  {
            ScrollView {
                VStack(spacing: 20) {
                    // MARK: - Header
                    PlayerHeaderSheet()
                    
                    // MARK: - XP Progress
                    UserLevelExperience()
                    
                    Divider().padding(.vertical, 8)
                    
                    // MARK: - Badges Section
                    BadgeAchievementsView()
                    
                    Divider().padding(.vertical, 8)
                    VStack(spacing: 10) {
                        statRow(icon: "clock.fill", title: "Best Streak days", value: "\(user.stats.bestStreakCount)")
                        statRow(icon: "bolt.fill", title: "Challenges Won", value: "\(user.stats.challengeWonCount)")
                        statRow(icon: "flame.fill", title: "Missions Completed", value: "\(user.stats.missionCompletedCount)")
                    }
                    
                    Divider().padding(.vertical, 8)
                    // MARK: - Level History
                    PlayerLevelProgression()
                }
                .padding(20)
                .offset(y: -40)
            }
            .background(theme.cardBackground)
            .scrollIndicators(.hidden)
            .toolbar {
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .symbolRenderingMode(.monochrome)
                            .font(.title3)
                            .foregroundStyle(theme.textSecondary.opacity(0.7))
                    }
                    .buttonStyle(.plain)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.hidden, for: .navigationBar)
        }
    }
}

#Preview {
    PlayerProfileSheet()
        .environment(\.currentUser, User.sampleUser())
    
}
