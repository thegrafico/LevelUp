//
//  UserLevelExpirience.swift
//  LevelUp
//
//  Created by Raúl Pichardo Avalo on 11/10/25.
//

import SwiftUI

struct UserLevelExperience: View {
    
    @Environment(\.theme) private var theme
    @Environment(\.currentUser) private var user
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Experience")
                .font(.headline)
                .foregroundStyle(theme.textSecondary)

            ProgressView(value: Double(user.stats.xp),
                         total: Double(user.stats.requiredXP()))
                .progressViewStyle(ThickLinearProgressStyle(height: 20))
                .animation(.easeOut(duration: 0.6), value: user.stats.xp)

            Text("\(user.stats.xp) / \(user.stats.requiredXP()) XP")
                .font(.caption.monospaced())
                .foregroundStyle(theme.textSecondary)
        }
    }
}

#Preview {
    UserLevelExperience()
        .padding(20)
        .environment(\.currentUser, User.sampleUser())
        .environment(\.theme, .orange)

}
