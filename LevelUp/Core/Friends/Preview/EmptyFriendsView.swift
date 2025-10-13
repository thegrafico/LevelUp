//
//  EmptyFriendsView.swift
//  LevelUp
//
//  Created by Raúl Pichardo Avalo on 10/11/25.
//

import SwiftUI

struct EmptyFriendsView: View {
    @Environment(\.theme) private var theme
    
    var onAddPressed: (() -> Void)? = nil

    var body: some View {
        VStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(theme.primary.opacity(0.1))
                    .frame(width: 90, height: 90)
                Image(systemName: "person.3.fill")
                    .font(.system(size: 36, weight: .semibold))
                    .foregroundStyle(theme.primary)
            }

            Text("No Friends Yet")
                .font(.title3.weight(.bold))
                .foregroundStyle(theme.textPrimary)

            Text("Add friends to start competing, sharing streaks, and sending challenges!")
                .font(.subheadline)
                .multilineTextAlignment(.center)
                .foregroundStyle(theme.textSecondary)
                .padding(.horizontal, 30)

            Button {
                // could open add friend sheet
                onAddPressed?()
            } label: {
                Label("Add Friends", systemImage: "person.badge.plus")
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(theme.textInverse)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: theme.cornerRadiusLarge)
                            .fill(theme.primary)
                    )
            }
            .buttonStyle(.plain)
            .padding(.top, 6)
        }
        .padding(.vertical, 60)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    EmptyFriendsView()
}
