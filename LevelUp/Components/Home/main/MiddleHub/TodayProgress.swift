//
//  TodayProgress.swift
//  LevelUp
//
//  Created by Raúl Pichardo Avalo on 9/26/25.
//

import SwiftUI

struct TodayProgress: View {
    @Environment(\.theme) private var theme
    var userXp: Double = 50.0
    var limitPointsPerDay: Double = User.LIMIT_POINTS_PER_DAY
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Today’s Progress")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(theme.textPrimary)

            ProgressView(value: userXp, total: limitPointsPerDay) { EmptyView() }
                .progressViewStyle(ThickLinearProgressStyle(height: 8))
                .frame(maxWidth: .infinity)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview {
    TodayProgress()
}
