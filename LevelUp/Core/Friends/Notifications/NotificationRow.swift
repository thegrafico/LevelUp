//
//  NotificationRow.swift
//  LevelUp
//
//  Created by Raúl Pichardo Avalo on 10/11/25.
//

import SwiftUI

struct NotificationRow: View {
    @Environment(\.theme) private var theme
    
    var notification: AppNotification
    var onViewTap: (AppNotification) -> Void
    
    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(theme.primary.opacity(0.15))
                    .frame(width: 48, height: 48)
                Image(systemName: notification.sender?.avatar ?? "person.circle.fill")
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundStyle(theme.primary)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(notification.sender?.username ?? "Unknown")
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(theme.textPrimary)
                Text(notification.message ?? "")
                    .font(.subheadline)
                    .foregroundStyle(theme.textSecondary)
                    .lineLimit(2)
            }
            
            Spacer()
            
            Button {
                notification.isRead = true
                print("Updating notification is read: \(notification.isRead)")
                onViewTap(notification)
            } label: {
                Text(notification.kind == .friendRequest ? "View" : "Challenge")
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(theme.textInverse)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(
                        Capsule().fill(theme.primary)
                    )
            }
            .buttonStyle(.plain)
            .disabled(notification.sender == nil)
            .opacity(notification.sender != nil ? 1 : 0.8)
        }
        .padding(10)
        .background(theme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: theme.cornerRadiusMedium))
        .shadow(color: theme.shadowLight.opacity(0.4), radius: 4, y: 2)
    }
}

#Preview {
    NotificationRow(notification: AppNotification(kind: .friendRequest,  sender: Friend(username: "thegraifco", stats: .init()), message: "Watns to connect"), onViewTap: {_ in})
    NotificationRow(notification: AppNotification(kind: .challenge, message: "challenges you"), onViewTap: {_ in})
}
