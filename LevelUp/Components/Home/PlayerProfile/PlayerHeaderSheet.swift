//
//  PlayerHeaderSheet.swift
//  LevelUp
//
//  Created by Raúl Pichardo Avalo on 11/10/25.
//

import SwiftUI

struct PlayerHeaderSheet: View {
    
    @Environment(\.theme) private var theme
    @Environment(\.currentUser) private var user
    
    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(theme.primary.opacity(0.15))
                    .frame(width: 100, height: 100)
                    .overlay(
                        Image(systemName: "person.fill")
                            .font(.system(size: 48, weight: .bold))
                            .foregroundStyle(theme.primary)
                    )
            }
            Text("@\(user.username)")
                .font(.title2.bold())
                .foregroundStyle(theme.textPrimary)
            Text("Level \(user.stats.level)")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding(.top, 10)
    }
}

#Preview {
    PlayerHeaderSheet()
        .environment(\.currentUser, User.sampleUser())

}
