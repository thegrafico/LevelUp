//
//  PendingFriendRequestView.swift
//  LevelUp
//
//  Created by Raúl Pichardo Avalo on 10/15/25.
//

import SwiftUI

struct PendingFriendRequestView: View {
    @Environment(\.theme) private var theme
    var friendRequests: [FriendRequest]

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Pending Requests")
                .font(.headline.weight(.semibold))
                .foregroundStyle(theme.textPrimary)
                .padding(.horizontal, 20)
                .padding(.top, 16)

            LazyVStack(spacing: 12) {
                ForEach(friendRequests) { request in
                    FriendRow(friend: request.to, onPressLabel: "Pending")
                        .disabled(true)
                        .opacity(0.5)
                        .padding(.horizontal, 20)
                }
            }
        }
    }
}

#Preview {
    PendingFriendRequestView(friendRequests: [SampleData.sampleFriendRequest1])
}
