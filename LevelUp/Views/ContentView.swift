//
//  ContentView.swift
//  LevelUp
//
//  Created by Raúl Pichardo Avalo on 9/4/25.
//

import SwiftUI

struct ContentView: View {
    @Environment(\.theme) private var theme
    @State private var badgeManager = BadgeManager()
    @State private var leaderBoardIsAvailable: Bool = true
    @Environment(\.modelContext) private var context
    @Environment(\.currentUser) private var user
    @Environment(\.scenePhase) private var scenePhase

    
    private var missionController: MissionController {
        MissionController(context: context, user: user, badgeManager: badgeManager)
    }

    var body: some View {
        VStack {
            
            TabView {
                
                Tab("Home", systemImage: "house") {
                    HomeView()
                        .environment(badgeManager)
                        .task {
                            // Runs when HomeView appears
                            await DataSeeder.loadGlobalMissions(for: user, in: context)
                            
                            await DataSeeder.loadLocalMissions(for: user, in: context)
                            
                            //                            await DataSeeder.addSampleLogs(for: user, in: context)
                            
                            let log = user.log(for: Date())
                            print("Getting todays log on change: \(log.date.formatted())")
                            
                            missionController.updateCompleteStatus(for: user.missions)
                            
                            badgeManager.clear(.HomeNotification)
                            
                        }
                        .onChange(of: scenePhase) { _, newPhase in
                            if newPhase == .active {
                                  
                                let log = user.log(for: Date())
                                print("Getting todays log from scene change: \(log.date.formatted())")
                                
                                missionController.updateCompleteStatus(for: user.missions)
                                
                               
                            }
                        }
                }
                .badge(badgeManager.count(for: .HomeNotification))
                
                

                Tab("Leaderboard", systemImage: "trophy.fill") {
                    LeaderboardView()
                        .task {
                            badgeManager.clear(.LeaderboardNotification)
                        }
                }
                .disabled(!leaderBoardIsAvailable)
                .badge(badgeManager.count(for: .LeaderboardNotification))

            
                
                Tab("Friends", systemImage: "person.3.fill") {
                    FriendsView()
                    .task {
                        badgeManager.clear(.FriendsNotification)
                    }
                }
                .badge(badgeManager.count(for: .FriendsNotification))

                
                Tab("Settings", systemImage: "gear") {
                   SettingsView()
                    .task {
                        badgeManager.clear(.SettingsNotification)
                    }
                }
                .badge(badgeManager.count(for: .SettingsNotification))
            }
            .tint(theme.primary)
            .toolbarBackground(theme.cardBackground, for: .tabBar)
            .background(theme.background.ignoresSafeArea())
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(SampleData.shared.modelContainer)
        .environment(\.theme, .orange)
        .environment(\.currentUser, User.sampleUserWithLogs())
}
