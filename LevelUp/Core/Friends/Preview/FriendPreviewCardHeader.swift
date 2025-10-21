//
//  FriendPreviewCardHeader.swift
//  LevelUp
//
//  Created by Raúl Pichardo Avalo on 10/21/25.
//

import SwiftUI

struct FriendPreviewCardHeader: View {
    
    @Environment(\.theme) private var theme
    
    var friend: Friend
    
    init(_ friend: Friend) {
        self.friend = friend
    }
    
    var body: some View {
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
    }
}

#Preview {
    FriendPreviewCardHeader(Friend(username: "thegrafico", stats: .init(bestStreakCount: 20)))
}
