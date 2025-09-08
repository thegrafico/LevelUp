//
//  HomeHeaderCard.swift
//  LevelUp
//
//  Created by Raúl Pichardo Avalo on 9/6/25.
//

import SwiftUI

struct TopBannerBackground: View {
    @Environment(\.theme) private var theme

    var height: CGFloat = 220
    var radius: CGFloat = 60

    var body: some View {
        LinearGradient(
            colors: [theme.primary, theme.primary.opacity(0.75)],  // simple on-brand gradient
            startPoint: .topLeading, endPoint: .bottomTrailing
        )
        .overlay(
            LinearGradient(
                colors: [.white.opacity(0.12), .clear],
                startPoint: .top,
                endPoint: .bottom
                )
        )
        .frame(
            maxWidth: .infinity,
            minHeight: height,
            maxHeight: height
        )
        .mask(
            UnevenRoundedRectangle(
                topLeadingRadius: 0,
                bottomLeadingRadius: radius,
                bottomTrailingRadius: radius,
                topTrailingRadius: 0,
                style: .continuous
            )
        )
        .shadow(color: theme.shadowDark, radius: 16, y: 8)
    }
}
#Preview {
    TopBannerBackground()
        .environment(\.theme, .orange)
}
