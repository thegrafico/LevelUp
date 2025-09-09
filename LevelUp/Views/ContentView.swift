//
//  ContentView.swift
//  LevelUp
//
//  Created by Raúl Pichardo Avalo on 9/4/25.
//

import SwiftUI

struct ContentView: View {
    @Environment(\.theme) private var theme   // ← get your theme

    var body: some View {
        VStack {
            
            TabView {
                
                Tab("Home", systemImage: "house") {
                    HomeView()
                }
                
                Tab("Leaderboard", systemImage: "trophy.fill") {
                    LeaderboardView()
                }
                
                Tab("Friends", systemImage: "person.3.fill") {
                    FriendsView()
                }
                
                Tab("Settings", systemImage: "gear") {
                    Text("Settings")
                }
            }
            .tint(theme.primary)
            .toolbarBackground(theme.cardBackground, for: .tabBar)
            .background(theme.background.ignoresSafeArea())
        }
    }
}

#Preview {
    ContentView()
        .environment(\.theme, .orange)
}
