//
//  MissionRequestPreview.swift
//  LevelUp
//
//  Created by Raúl Pichardo Avalo on 11/6/25.
//

import SwiftUI


struct MissionRequestPreview: View {
    @Environment(\.theme) private var theme
    @Environment(\.dismiss) private var dismiss
    @Environment(\.currentUser) private var user
    @EnvironmentObject private var modalManager: ModalManager
    
    // MARK: - Loading States
    @State private var isActionLoading = false
    @State private var isCancelLoading = false
    @State private var requestSuccess  = false
    //    @State private var isEditing = false
    
    
    var missionRequest: MissionRequest
    
    private var friend: Friend {
        missionRequest.from
    }
    
    private var mission: Mission {
        missionRequest.mission
    }
    
    var onAction: ((Friend) async throws -> Void)? = nil
    var onCancel: ((Friend) async throws -> Void)? = nil
    var onActionDelete: (() async throws -> Void)? = nil
    
    var onActionTitle: String? = nil
    var onActionCancel: String? = nil
    
    var isMyFriend: Bool {
        user.hasFriend(withId: friend.friendId)
    }
    
    // MARK: - Body
    var body: some View {
        NavigationStack {
            
            VStack(spacing: 16) {
                
                FriendPreviewCardHeader(friend)
                
                Divider().padding(.vertical, 8)
                
                VStack(spacing: 12) {
                    
                    Text("@\(friend.username) sent you a mission.")
                        .font(.subheadline)
                        .foregroundStyle(theme.textSecondary)
                    
                    VStack {
                        
                        VStack(spacing: 8) {
                            Text(mission.title)
                                .font(.headline)
                                .foregroundStyle(theme.textInverse)
                                .padding(.horizontal, 14)
                                .padding(.vertical, 8)
                                .lineLimit(2)
                                .background(theme.primary.opacity(0.8))
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                            
                            HStack {
                                Text("\(mission.xp) XP")
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundStyle(theme.primary)
                                    .lineLimit(1)
                                    .fixedSize()
                                
                                Text("•")
                                    .foregroundStyle(theme.textSecondary.opacity(0.5))
                                
                                Text(mission.category.name )
                                    .font(.subheadline.weight(.medium))
                                    .foregroundStyle(theme.textSecondary.opacity(0.5))
                                
                                Text("•")
                                    .foregroundStyle(theme.textSecondary.opacity(0.5))
                                
                                Button {
                                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                } label: {
                                    HStack(spacing: 4) {
                                        Image(systemName: "square.and.arrow.up") // share icon
                                            .font(.caption.bold())
                                        Text(mission.type == .global ? "GLOBAL" : "CUSTOM")
                                            .font(.caption.weight(.bold))
                                            .lineLimit(1)
                                    }
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 6)
                                    .background(
                                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                                            .fill(theme.accent.opacity(0.18))
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 8)
                                                    .stroke(theme.accent.opacity(0.4), lineWidth: 1)
                                            )
                                            .shadow(color: theme.accent.opacity(0.25), radius: 3, y: 2)
                                    )
                                    .foregroundStyle(theme.primary)
                                    .contentShape(Rectangle()) // expands tap area
                                }
                                .buttonStyle(.scaleOnTap) // 👈 custom animation (below)
                            }
                            .padding(.top, 4)
                        }
                    }
                    .frame(width: 300)
                    .padding()
                    
                    .background(theme.background)
                    .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
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
                                    requestSuccess = true
                                    try await Task.sleep(nanoseconds: 600_000_000)
                                    dismiss()
                                } catch {
                                    print("❌ Cancel action failed: \(error.localizedDescription)")
                                }
                                isCancelLoading = false
                                try await Task.sleep(nanoseconds: 600_000_000)
                                requestSuccess = false
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
        }
    }
}


extension MissionRequestPreview {
    // MARK: - Dynamic Titles
    var actionTitle: Text {
        if let custom = onActionTitle { return Text(custom) }
        
        return Text(Image(systemName: "hand.thumbsup.fill")) + Text(" Accept")
}
    
    var cancelTitle: Text {
        if let custom = onActionCancel { return Text(custom) }
        
        return Text(Image(systemName: "hand.thumbsdown.fill")) + Text(" Decline")
       
    }
}

#Preview {
    
    let testFriend = Friend(
        username: "Thegrafico",
        stats: UserStats(level: 20, bestStreakCount: 10, topMission: "Drink Water", challengeWonCount: 4)
    )
    
    let mission = Mission(
        title: "Drink Water",
        xp: 100,
        details: "Drink 1 liter of water",
        icon: "plus"
    )
    
    let missionRequest = MissionRequest(
        from: testFriend,
        to: testFriend,
        mission: mission,
        status: .pending
    )
    
    MissionRequestPreview(missionRequest: missionRequest)
        .environmentObject(ModalManager())
        .environment(\.currentUser, User.sampleUserWithLogs(), )
    
    
}


