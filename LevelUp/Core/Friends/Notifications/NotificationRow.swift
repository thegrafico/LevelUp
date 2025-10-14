//
//  NotificationRow.swift
//  LevelUp
//
//  Created by Raúl Pichardo Avalo on 10/11/25.
//

import SwiftUI

struct AppNotification: Identifiable {
    
    enum Kind: String, CaseIterable {
        case friendRequest = "Friend Requests"
        case challenge = "Challenges"
        case system = "System"
    }

    var id: UUID = UUID()
    var title: String {
        kind.rawValue
    }
    var kind: Kind
    var message: String?
    var sender: Friend?
    var isRead: Bool = false
    
    var payload: Any?
//    private var payloadId: UUID {
//        switch kind {
//        case .friendRequest(let request): return request.id
//        case .challenge(let challenge): return challenge.id
//        }
//    }
//    
//    private var payload: Any {
//        switch kind {
//            case .friendRequest(let request): return request
//            case .challenge(let challenge): return challenge
//        }
//    }
}

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
                onViewTap(notification)
            } label: {
                Text(notification.kind == .friendRequest ? "Request" : "Challenge")
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(theme.textInverse)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(
                        Capsule().fill(theme.primary)
                    )
            }
            .buttonStyle(.plain)
        }
        .padding(10)
        .background(theme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: theme.cornerRadiusMedium))
        .shadow(color: theme.shadowLight.opacity(0.4), radius: 4, y: 2)
    }
}

#Preview {
    NotificationRow(notification: AppNotification(kind: .friendRequest, message: "Watns to connect"), onViewTap: {_ in})
    NotificationRow(notification: AppNotification(kind: .challenge, message: "challenges you"), onViewTap: {_ in})
}
