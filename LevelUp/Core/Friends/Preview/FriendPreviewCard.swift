//
//  FriendsPreviewCard.swift
//  LevelUp
//
//  Created by Raúl Pichardo Avalo on 10/11/25.
//

import SwiftUI

struct FriendPreviewCard: View {
    @Environment(\.theme) private var theme
    @Environment(\.dismiss) private var dismiss

    var friend: Friend
    var type: AppNotification.Kind? = nil
    var onAction: ((Friend) async throws -> Void)? = nil
    var onCancel: ((Friend) async throws -> Void)? = nil

    var onActionTitle: String? = nil
    var onActionCancel: String? = nil

    // MARK: - Loading States
    @State private var isActionLoading = false
    @State private var isCancelLoading = false
    @State private var requestSuccess  = false

    // MARK: - Dynamic Titles
    var actionTitle: Text {
        if let custom = onActionTitle { return Text(custom) }

        switch type {
        case .challenge:
            return Text("⚔️ Accept")
        case .friendRequest:
            return Text(Image(systemName: "hand.thumbsup.fill")) + Text(" Accept")
        case .system, .preview, .none:
            return Text("Close")
        }
    }

    var cancelTitle: Text {
        if let custom = onActionCancel { return Text(custom) }

        switch type {
        case .challenge:
            return Text(Image(systemName: "xmark.circle.fill")) + Text(" Not Now")
        case .friendRequest:
            return Text(Image(systemName: "hand.thumbsdown.fill")) + Text(" Decline")
        case .system, .preview, .none:
            return Text("Close")
        }
    }

    // MARK: - Body
    var body: some View {
        VStack(spacing: 16) {
            Circle()
                .fill(theme.primary.opacity(0.15))
                .frame(width: 100, height: 100)
                .overlay(
                    Image(systemName: friend.avatar)
                        .font(.system(size: 50, weight: .bold))
                        .foregroundStyle(theme.primary)
                )

            Text("@\(friend.username)")
                .font(.title2.weight(.bold))
                .foregroundStyle(theme.textPrimary)

            HStack {
                Text("Level \(friend.stats.level)")
                    .font(.subheadline)
                    .foregroundStyle(theme.textSecondary)

                if friend.stats.bestStreakCount > 0 {
                    Text("• Best Streak: \(friend.stats.bestStreakCount) days")
                        .font(.subheadline)
                        .foregroundStyle(theme.textSecondary)
                }
            }

            Divider().padding(.vertical, 8)

            VStack(spacing: 10) {
                statRow(icon: "flame.fill", title: "Challenges Won", value: "\(friend.stats.challengeWonCount)")
                statRow(icon: "bolt.fill", title: "Top Mission", value: "\(friend.stats.topMission ?? "None")")
                statRow(icon: "clock.fill", title: "Last Active", value: "2 hours ago")
            }

            Spacer()

            // MARK: - Action Buttons
            HStack(spacing: 12) {
                // Optional cancel / deny button
                if let onCancel {
                    Button {
                        Task {
                            isCancelLoading = true
                            do {
                                try await onCancel(friend)
                                isCancelLoading = false
                                requestSuccess = true
                                try await Task.sleep(nanoseconds: 1_000_000_000)
                                dismiss()
                            } catch {
                                print("❌ Cancel action failed: \(error.localizedDescription)")
                            }
                            isCancelLoading = false
                        }
                    } label: {
                        if isCancelLoading {
                            ProgressView()
                                .tint(theme.destructive)
                        } else if requestSuccess {
                            Text(Image(systemName: "hand.thumbsup.fill")) + Text(" Done")
                                .font(.headline.weight(.semibold))
                        } else {
                            cancelTitle
                                .font(.headline.weight(.semibold))
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: theme.cornerRadiusLarge)
                            .fill(theme.destructiveBackground)
                    )
                    .foregroundStyle(theme.destructive)
                    .disabled(isActionLoading)
                }

                // Main confirm / send button
                Button {
                    Task {
                        isActionLoading = true
                        do {
                            try await onAction?(friend)
                            try await Task.sleep(nanoseconds: 1_000_000_000)
                            dismiss()
                        } catch {
                            print("❌ Action failed: \(error.localizedDescription)")
                        }
                        isActionLoading = false
                    }
                } label: {
                    if isActionLoading {
                        ProgressView()
                            .tint(theme.textInverse)
                    } else {
                        actionTitle
                            .font(.headline.weight(.semibold))
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: theme.cornerRadiusLarge)
                        .fill(theme.primary)
                )
                .foregroundStyle(theme.textInverse)
                .disabled(isCancelLoading)
                .opacity(isCancelLoading ? 0.5 : 1)
            }
        }
        .padding(20)
        .background(theme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: theme.cornerRadiusLarge))
        .shadow(color: theme.shadowLight, radius: 10, y: 4)
        .presentationBackground(theme.background)
    }

    @ViewBuilder
    private func statRow(icon: String, title: String, value: String) -> some View {
        HStack {
            Image(systemName: icon)
                .foregroundStyle(theme.primary)
            Text(title)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(theme.textPrimary)
            Spacer()
            Text(value)
                .font(.subheadline)
                .foregroundStyle(theme.textSecondary)
        }
    }
}

#Preview {
    
    let testFriend = Friend(
        username: "Thegrafico",
        stats: UserStats(level: 20, bestStreakCount: 10, topMission: "Drink Water", challengeWonCount: 4)
    )
    
    FriendPreviewCard(friend: testFriend, type: .challenge, onCancel: {_ in})
}
