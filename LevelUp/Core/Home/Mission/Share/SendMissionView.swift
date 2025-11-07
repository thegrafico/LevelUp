//
//  SendMissionView.swift
//  LevelUp
//
//  Created by Raúl Pichardo Avalo on 11/2/25.
//

import SwiftUI

struct SendMissionView: View {
    @Environment(\.theme) private var theme
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    @Environment(\.currentUser) private var user
    
    @Bindable var mission: Mission
    var friends: [Friend]
    
    @State private var isSendingToAll = false
    @State private var sendErrors: [UUID: String] = [:]
    
    private var missionController: MissionController {
        MissionController(
            context: context,
            user: user,
        )
    }
    
    var body: some View {
        VStack(spacing: 18) {
            
            // 🔝 Header
            VStack(spacing: 4) {
                Text("Send Mission")
                    .font(.title3.weight(.bold))
                    .foregroundStyle(theme.textPrimary)
                Text("Challenge your friends to join this quest.")
                    .font(.subheadline)
                    .foregroundStyle(theme.textSecondary)
            }
            .padding(.top, 8)
            
            // 🧾 Mission summary card
            HStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(theme.accent.opacity(0.15))
                        .frame(width: 52, height: 52)
                    Image(systemName: mission.icon)
                        .font(.system(size: 22, weight: .bold))
                        .foregroundStyle(theme.accent)
                }
                VStack(alignment: .leading, spacing: 3) {
                    Text(mission.title)
                        .font(.headline.weight(.semibold))
                        .foregroundStyle(theme.textPrimary)
                    Text("\(mission.xp) XP")
                        .font(.footnote.weight(.medium))
                        .foregroundStyle(theme.textSecondary)
                }
                Spacer()
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(theme.cardBackground)
                    .shadow(color: theme.shadowLight, radius: 6, y: 3)
            )
            .padding(.horizontal)
            
            // 🧑‍🤝‍🧑 Friend list
            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(friends) { friend in
                        FriendRow(
                            friend: friend,
                            onPressLabel: "Send",
                            updateLabelOnComplete: true,
                            externalError: sendErrors[friend.id]
                        ) { f in
                            try await sendMission(to: f)
                        }
                    }
                    .padding(.horizontal, 20)
                }
                .padding(.vertical, 8)
            }
            
            // 📤 Send to all button
            if !friends.isEmpty {
                Button {
                    Task { await sendToAllFriends() }
                } label: {
                    HStack {
                        if isSendingToAll {
                            ProgressView()
                                .tint(theme.textInverse)
                        } else {
                            Image(systemName: "paperplane.fill")
                            Text("Send to All")
                                .fontWeight(.semibold)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .background(theme.primary)
                    .foregroundStyle(theme.textInverse)
                    .clipShape(Capsule())
                    .shadow(color: theme.primary.opacity(0.4), radius: 6, y: 3)
                }
                .disabled(isSendingToAll)
                .padding(.top, 6)
                .padding(.bottom, 12)
            }
        }
        .frame(maxHeight: .infinity, alignment: .top)
        .background(theme.background.ignoresSafeArea())
        .padding(.top, 10)
    }
    
    // MARK: Sending mission
    private func sendMission(to friend: Friend) async throws {
        
        // MARK: Sending mission request
        try await missionController.sendMission(mission, to: friend)
        
        // Just for testing pourpose
        try await Task.sleep(nanoseconds: 700_000_000)
        
        print("✅ Sent mission '\(mission.title)' to \(friend.username)")
    }
    
    private func sendToAllFriends() async {
        isSendingToAll = true
        for friend in friends {
            do {
                try await sendMission(to: friend)
            } catch {
                sendErrors[friend.id] = error.localizedDescription
            }
        }
        isSendingToAll = false
    }
}

#Preview {
    SendMissionView(
        mission: Mission(title: "Grow up", xp: 20, icon: "plus"),
        friends: [
            Friend(username: "Thegrafico", stats: .init()),
            Friend(username: "Test", stats: .init()),
            Friend(username: "Test", stats: .init()),
            Friend(username: "Test", stats: .init()),
            Friend(username: "Test", stats: .init()),
            Friend(username: "Test", stats: .init()),
            Friend(username: "Test", stats: .init()),
            Friend(username: "Test", stats: .init()),
            Friend(username: "Test", stats: .init()),
            Friend(username: "Test", stats: .init()),
            Friend(username: "Test", stats: .init()),
            Friend(username: "Test", stats: .init()),
        ])
}
