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
//                .task {
//                    exportIcons()
//                }

        }
    }
    
    @MainActor
    private func exportIcons() {
           let sizes: [CGFloat] = [1024, 512, 256, 128]

           for size in sizes {
               let icon = XPAppIcon(size: size, forAppStore: true)
                   .environment(\.theme, .orange)

               let renderer = ImageRenderer(content: icon)

               if let uiImage = renderer.uiImage {
                   if let data = uiImage.pngData() {
                       // Save inside app’s Documents directory (works on iOS Simulator)
                       let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                       let url = documents.appendingPathComponent("XPAppIcon_\(Int(size)).png")

                       do {
                           try data.write(to: url)
                           print("✅ Exported: \(url)")
                       } catch {
                           print("❌ Failed to save: \(error)")
                       }
                   }
               }
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
