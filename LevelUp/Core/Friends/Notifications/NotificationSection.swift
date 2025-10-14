//
//  NotificationSection.swift
//  LevelUp
//
//  Created by Raúl Pichardo Avalo on 10/11/25.
//

import SwiftUI

struct NotificationSection: View {
    @Environment(BadgeManager.self) private var badgeManager: BadgeManager?
    @Environment(\.theme) private var theme
    
    var title: String
    var notifications: [AppNotification]
    var isExpanded: Bool
    var onToggle: () -> Void
    var onViewTap: (AppNotification) -> Void
    
    var notificationBadgeType: AppNotification.Kind {
        
        if let firtsElementKind = notifications.first?.kind {
            return firtsElementKind
        }
        
        return .system
    }
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Text(title)
                    .font(.headline.weight(.bold))
                    .foregroundStyle(theme.textPrimary)
                    .overlay(alignment: .topTrailing) {
                        if let badgeManager = badgeManager {
                            
                            let count = badgeManager.count(for: .AppNotification(notificationBadgeType))
                            if count > 0 {
                                BadgeView(count: count, size: 20)
                                    .offset(x: 14, y: -14)
                            } else {
                                EmptyView()
                            }
                        }
                    }
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
    NotificationSection(title: "Challenge", notifications: [], isExpanded: true, onToggle: {}, onViewTap: {_ in})
        .environment(BadgeManager(defaultCount: 2)) // 👈 inject preview manager

}
