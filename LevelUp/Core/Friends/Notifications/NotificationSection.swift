//
//  NotificationSection.swift
//  LevelUp
//
//  Created by Raúl Pichardo Avalo on 10/11/25.
//

import SwiftUI

struct NotificationSection: View {
    @Environment(\.theme) private var theme
    var title: String
    var notifications: [UserNotification]
    var isExpanded: Bool
    var onToggle: () -> Void
    var onViewTap: (UserNotification) -> Void
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Text(title)
                    .font(.headline.weight(.bold))
                    .foregroundStyle(theme.textPrimary)
                Spacer()
                Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                    .foregroundStyle(theme.textSecondary)
                    .font(.subheadline)
            }
            .padding(.horizontal, 8)
            .contentShape(Rectangle())
            .onTapGesture(perform: onToggle)
            .padding(.bottom, 4)
            
            if isExpanded {
                VStack(spacing: 12) {
                    ForEach(notifications) { note in
                        NotificationRow(notification: note, onViewTap: onViewTap)
                    }
                }
                .transition(.opacity.combined(with: .slide))
            }
        }
        .padding()
        .background(theme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: theme.cornerRadiusLarge))
        .shadow(color: theme.shadowLight, radius: 8, y: 4)
        .animation(.spring(response: 0.4, dampingFraction: 0.7), value: isExpanded)
    }
}

#Preview {
    NotificationSection(title: "None", notifications: [], isExpanded: true, onToggle: {}, onViewTap: {_ in})
}
