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
            .frame(width: 70, height: 70)
            .overlay(
                Image(systemName: friend.avatar)
                    .font(.system(size: 50, weight: .bold))
                    .foregroundStyle(theme.primary)
            )
            .padding(.top, 20)
        
        HStack (spacing: 0) {
            
            Text("@\(friend.username)")
                .font(.title2.weight(.bold))
                .foregroundStyle(theme.textPrimary)
            
            
            // ⭐ Favorite toggle
            Button {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                    friend.isFavorite.toggle()
                }
            } label: {
                Image(systemName: friend.isFavorite ? "star.fill" : "star")
                    .symbolRenderingMode(.hierarchical)
                    .foregroundStyle(friend.isFavorite ? theme.primary : .secondary)
                    .font(.title3)
                    .padding(6)
                    .contentShape(Rectangle())
                    .animation(.easeInOut, value: friend.isFavorite)
            }
            .buttonStyle(.plain)
            .accessibilityLabel(friend.isFavorite ? "Remove from favorites" : "Add to favorites")
            
        }
        
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
