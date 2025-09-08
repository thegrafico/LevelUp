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
    var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(for: Mission.self)
                .environment(\.theme, .orange)   // inject theme here
        }
    }
}
