//
//  TodayProgress.swift
//  LevelUp
//
//  Created by Raúl Pichardo Avalo on 9/26/25.
//

import SwiftUI

struct TodayProgress: View {
    @Environment(\.theme) private var theme
    @Environment(\.currentUser) private var user
    @Binding var showTodaysProgressSheet: Bool

    var limitPointsPerDay: Double = User.LIMIT_POINTS_PER_DAY
    
    var body: some View {
        Button {
            UIImpactFeedbackGenerator(style: .soft).impactOccurred()
            showTodaysProgressSheet.toggle()
        } label: {
        
            VStack(alignment: .leading, spacing: 6) {
                Text("Today’s Progress")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(theme.textPrimary)

                ProgressView(
                    value: user.clampedXpToday,
                    total: limitPointsPerDay
                ) { EmptyView() }
                    .progressViewStyle(ThickLinearProgressStyle(height: 8))
                    .frame(maxWidth: .infinity)
                    .animation(.easeOut(duration: 0.6), value: user.xpGainedToday) // smooth fill animation
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

#Preview {
    TodayProgress(showTodaysProgressSheet: .constant(false))
        .modelContainer(SampleData.shared.modelContainer)
        .environment(\.theme, .orange)
        .environment(BadgeManager())
        .environment(\.currentUser, User.sampleUser())
}
