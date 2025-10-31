//
//  LevelUpApp.swift
//  LevelUp
//
//  Created by Raúl Pichardo Avalo on 9/4/25.
//
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
    
    @AppStorage("selectedTheme") private var selectedThemeRawValue: String = ThemeOption.system.rawValue
    @Environment(\.colorScheme) private var colorScheme
    
    private var currentTheme: Theme {
         // Safely resolve theme based on stored preference + system mode
         let option = ThemeOption(rawValue: selectedThemeRawValue) ?? .system
         return option.resolve(using: colorScheme)
     }
    
    var body: some Scene {
        WindowGroup {
            RootGate()
                .modelContainer(for: [
                    AppNotification.self,
                    Friend.self,
                    FriendRequest.self,
                    Mission.self,
                    ProgressLog.self,
                    User.self,
                    UserSettings.self,
                    UserStats.self
                ])
                .preferredColorScheme(.light)
                .environment(\.theme, currentTheme)
                .environmentObject(userStore)
        }
    }
}

struct RootGate: View {
    @Environment(\.modelContext) private var context
    @EnvironmentObject private var userStore: UserStore
    
    @State private var state: LaunchState = .loading
    
    var body: some View {
        ZStack {
            switch state {
            case .loading:
                SplashLoadingView()
            case .authenticated(let user):
                ContentView()
                    .environment(\.currentUser, user)
                    .transition(.move(edge: .trailing).combined(with: .opacity))
            case .unauthenticated:
                AuthView()
                    .transition(.move(edge: .leading).combined(with: .opacity))
            }
            
            // 👇 overlay global busy splash if any async operation is running
            if userStore.isBusy {
                SplashLoadingView(message: userStore.busyMessage)
                    .transition(.opacity)
                    .zIndex(1)
            }
        }
        .task { await restoreSession() }
        .onAppear { userStore.attachContext(context) }
        .onChange(of: userStore.user) { _, newUser in
            withAnimation(.spring(duration: 0.35)) {
                if let u = newUser {
                    state = .authenticated(u)
                } else {
                    state = .unauthenticated
                }
            }
        }
    }
    
    @MainActor
    private func restoreSession() async {
        state = .loading
        if let id = userStore.getActiveUserId(),
           let user = await DataSeeder.loadUserIfNeeded(into: context, activeUserId: id) {
            userStore.user = user
            withAnimation(.spring(duration: 0.35)) {
                state = .authenticated(user)
            }
        } else {
//            
//            do {
//                try await Task.sleep(nanoseconds: 1_000_000_000 * 2) // 2s
//                
//                let sampleUser = try DataSeeder.insertDummyData(into: context)
//                
//                userStore.setUser(sampleUser)
//                
//                withAnimation(.spring(duration: 0.35)) {
//                    state = .authenticated(sampleUser)
//                }
//                return
//                
//            } catch {
//                print("❌ Failed to create sample user: \(error)")
//            }
//            
            
            withAnimation(.spring(duration: 0.35)) {
                state = .unauthenticated
            }
        }
    }
}

enum LaunchState {
    case loading
    case authenticated(User)
    case unauthenticated
}
