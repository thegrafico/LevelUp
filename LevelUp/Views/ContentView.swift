//
//  ContentView.swift
//  LevelUp
//
//  Created by Raúl Pichardo Avalo on 9/4/25.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            
            TabView {
                
                Tab("Home", systemImage: "house") {
                    HomeView()
                }
                
                Tab("Leaderboard", systemImage: "trophy.fill") {
                    Text("Board")
                }
                
                Tab("Friends", systemImage: "person.3.fill") {
                    Text("Friends")
                }
                
                Tab("Settings", systemImage: "gear") {
                    Text("Settings")
                }
            }
            .tint(.orange)
        }
    }
}

#Preview {
    ContentView()
}
