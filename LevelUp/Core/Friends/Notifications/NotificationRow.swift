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
    var onViewTap: (AppNotification) async throws -> Void
    
    @State private var isLoading = false
    @State private var didFail = false
    
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
                guard !isLoading else { return }
                Task {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        isLoading = true
                        didFail = false
                        
                    }

                    do {
                        notification.isRead = true
                        try await onViewTap(notification)
                    } catch {
                        print("❌ Notification action failed: \(error.localizedDescription)")
                        withAnimation(.easeInOut) { didFail = true }
                        // optional haptic feedback
                        UIImpactFeedbackGenerator(style: .rigid).impactOccurred()
                        try? await Task.sleep(nanoseconds: 1_000_000_000)
                        withAnimation(.easeOut) { didFail = false }
                    }
                    withAnimation(.easeInOut(duration: 0.2)) {
                        isLoading = false
                    }
                }
            } label: {
                ZStack {
                    if isLoading {
                        ProgressView()
                            .progressViewStyle(.circular)
                            .tint(theme.textInverse)
                            .frame(width: 40, height: 16)
                    } else {
                        Text(didFail ? "Retry" : "View")
                            .font(.footnote.weight(.semibold))
                            .foregroundStyle(theme.textInverse)
                            .frame(minWidth: 40)
                    }
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(
                    Capsule().fill(
                        didFail ? theme.destructive.opacity(0.8) : theme.primary
                    )
                )
                .animation(.spring(response: 0.35, dampingFraction: 0.8), value: isLoading)
            }
            .buttonStyle(.plain)
            .disabled(notification.sender == nil || isLoading)
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
