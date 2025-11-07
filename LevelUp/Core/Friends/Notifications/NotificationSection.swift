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
    var onViewTap: (AppNotification) async throws -> Void
    var notificationBadgeType: AppNotification.Kind {
        
        if let firtsElementKind = notifications.first?.kind {
            return firtsElementKind
        }
        
        return .system
    }
    
    // MARK: NEW NOTIFICATIONS COUNTER
    var newNotificationsCount: Int {
        notifications.filter({!$0.isRead}).count
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
            .onTapGesture() {
                badgeManager?.clear(.AppNotification(notificationBadgeType))
                onToggle()
            }
            .padding(.bottom, 4)
            
            if isExpanded {
                VStack(spacing: 12) {
                    ForEach(notifications) { note in
                        NotificationRow(notification: note, onViewTap: onViewTap)
                            .transition(.fadeRightToLeft)
                    }
                    .animation(.spring(response: 0.4, dampingFraction: 0.8), value: notifications)
                    
                }
            
                .transition(.opacity.combined(with: .slide))
            }
        }
        .padding()
        .background(theme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: theme.cornerRadiusLarge))
        .shadow(color: theme.shadowLight, radius: 8, y: 4)
        .animation(.spring(response: 0.4, dampingFraction: 0.7), value: isExpanded)
        .onAppear() {
            incrementBadgeCount()
        }
    }
}

extension NotificationSection {
    func incrementBadgeCount() {
//        print("Checking badge count: \(newNotificationsCount)")
        badgeManager?.set(.AppNotification(notificationBadgeType), to: newNotificationsCount)
    }
}

struct StatefulPreviewWrapper<Value, Content: View>: View {
    @State private var value: Value
    var content: (Binding<Value>) -> Content

    init(_ value: Value, @ViewBuilder content: @escaping (Binding<Value>) -> Content) {
        _value = State(initialValue: value)
        self.content = content
    }

    var body: some View {
        content($value)
    }
}

#Preview {
    NotificationSection(title: "Notificqtions", notifications: SampleData.sampleAppNotifications, isExpanded: true, onToggle: {}, onViewTap: {_ in})
        
        .environment(BadgeManager()) // 👈 inject preview manager

}
