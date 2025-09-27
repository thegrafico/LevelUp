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
    @StateObject private var userStore = UserStore(user: User.sampleUser())

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
    @EnvironmentObject private var userStore: UserStore

    var body: some View {
        if let user = userStore.user {
            ContentView()
                .environment(\.currentUser, user)
        } else {
            AuthView()
        }
    }
}
