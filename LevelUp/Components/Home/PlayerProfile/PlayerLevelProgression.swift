//
//  PlayerLevelProgression.swift
//  LevelUp
//
//  Created by Raúl Pichardo Avalo on 11/10/25.
//

import SwiftUI

struct PlayerLevelProgression: View {
    @Environment(\.theme) private var theme
    @Environment(\.currentUser) private var user

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Level Progression")
                .font(.headline)
                .foregroundStyle(theme.textSecondary)

            if user.levelProgressionLogs.isEmpty {
                Text("No level history yet.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .padding(.top, 6)
            } else {
                ForEach(user.levelProgressionLogs) { log in
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Reached Lv. \(log.level)")
                                .font(.subheadline.bold())
                            Text(log.date.formatted(date: .abbreviated, time: .omitted))
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                        Text("+\(log.gainedXP) XP")
                            .font(.footnote.monospaced())
                            .foregroundStyle(theme.primary)
                    }
                    .padding(10)
                    .background(theme.cardBackground)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                }
            }
        }
    }
}

struct LevelLog: Identifiable {
    let id = UUID()
    let level: Int
    let gainedXP: Int
    let date: Date
}


private let sampleLevelHistory = [
    LevelLog(level: 2, gainedXP: 150, date: .now.addingTimeInterval(-86400 * 7)),
    LevelLog(level: 3, gainedXP: 200, date: .now.addingTimeInterval(-86400 * 5)),
    LevelLog(level: 4, gainedXP: 300, date: .now.addingTimeInterval(-86400 * 2))
]

#Preview {
    PlayerLevelProgression()
        .padding(20)
        .environment(\.currentUser, User.sampleUserWithLevelUps())

}
