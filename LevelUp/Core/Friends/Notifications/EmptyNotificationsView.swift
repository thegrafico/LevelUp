//
//  EmptyNotificationsView.swift
//  LevelUp
//
//  Created by Raúl Pichardo Avalo on 10/15/25.
//

import SwiftUI

struct EmptyNotificationsView: View {
    @Environment(\.theme) private var theme

    var body: some View {
        // 👇 Empty state view
        VStack(spacing: 12) {
            Image(systemName: "bell.slash.fill")
                .font(.system(size: 48))
                .foregroundStyle(theme.textSecondary.opacity(0.5))
            Text("No notifications yet")
                .font(.headline)
                .foregroundStyle(theme.textSecondary)
            Text("When you receive friend requests or updates, they’ll appear here.")
                .font(.subheadline)
                .multilineTextAlignment(.center)
                .foregroundStyle(theme.textSecondary.opacity(0.7))
                .padding(.horizontal, 24)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(theme.background.ignoresSafeArea())
    }
}

#Preview {
    EmptyNotificationsView()
}
