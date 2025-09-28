//
//  LevelUpApp.swift
//  LevelUp
//
//  Created by Raúl Pichardo Avalo on 9/4/25.
//

import SwiftUI
import SwiftData

@main
struct LevelUpApp: App {
    @StateObject private var userStore = UserStore()

    var body: some Scene {
        WindowGroup {
            RootGate()
                .modelContainer(for: [
                    User.self,
                    Mission.self,
                    Friend.self,
                    FriendRequest.self,
                    ProgressLog.self,
                    UserSettings.self
                ])
                .preferredColorScheme(.light)
                .environment(\.theme, .orange)
                .environmentObject(userStore)

        }
    }
}

struct RootGate: View {
    @Environment(\.modelContext) private var context
    @EnvironmentObject private var userStore: UserStore

    var body: some View {
        Group {
            if let user = userStore.user {
                ContentView()
                    .environment(\.currentUser, user)
                    .task {
//                        try? DataSeeder.clearAll(from: context)
                        await DataSeeder.loadGlobalMissions(into: context)
                        print("Loading User from UserStore: \(user.username)")
                    }
            } else {
                AuthView()
                    .task {
                        if let user = await DataSeeder.loadUserIfNeeded(into: context) {
                            userStore.user = user
                        }
                    }
            }
        }
    }
}
