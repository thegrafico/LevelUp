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
    @State private var animatedProgress: Double = 0

    var limitPointsPerDay: Double = User.LIMIT_POINTS_PER_DAY

    private func clamp(_ v: Double) -> Double {
        min(max(v, 0), limitPointsPerDay)
    }

    var body: some View {
        Button {
            UIImpactFeedbackGenerator(style: .soft).impactOccurred()
            showTodaysProgressSheet.toggle()
        } label: {
            VStack(alignment: .leading, spacing: 6) {
                Text("Today’s Progress")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(theme.textPrimary)

                ProgressView(value: animatedProgress, total: limitPointsPerDay)
                    .progressViewStyle(ThickLinearProgressStyle(height: 8))
                    .frame(maxWidth: .infinity)
                    .onAppear {
                        animatedProgress = clamp(user.clampedXpToday)
                    }
                    // Animate whenever the trigger changes
                    .onChange(of: user.lastRefreshTrigger) {
                        withAnimation(.easeOut(duration: 0.6)) {
                            animatedProgress = clamp(user.clampedXpToday)
                        }
                    }
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
