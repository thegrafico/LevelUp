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
    @Environment(\.currentUser) private var user

    
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
    
    // MARK: - Body
    var body: some View {
        NavigationStack {
            
            
            VStack(spacing: 16) {
                
                FriendPreviewCardHeader(friend)
                
                Divider().padding(.vertical, 8)
                
                FriendPreviewCardStatsOverview(friend.stats)
                
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
                                try await Task.sleep(nanoseconds: 600_000_000)
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
            .overlay(alignment: .topTrailing) {
                
                // MARK: EDIT FRIEND: [add to favorite, remove]
                if user.hasFriend(withId: friend.friendId) {
                    Button {
                        print("Edit tapped for \(friend.username)")
                    } label: {
                        Text("Edit")
                            .font(.headline.weight(.semibold))
                    }
                    .tint(theme.primary)
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                } else {
                    EmptyView()
                }
                
            }
        }
    }
}

extension FriendPreviewCard {
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
}

#Preview {
    
    let testFriend = Friend(
        username: "Thegrafico",
        stats: UserStats(level: 20, bestStreakCount: 10, topMission: "Drink Water", challengeWonCount: 4)
    )
    
    FriendPreviewCard(friend: testFriend, type: .challenge, onCancel: {_ in})
}
