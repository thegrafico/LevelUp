//
//  Friends.swift
//  LevelUp
//
//  Created by Raúl Pichardo Avalo on 9/10/25.
//

import Foundation
import SwiftData

@Model
final class Friend: Identifiable {
    var id: UUID
    var friendId: UUID
    var username: String
    var avatar: String
    var relationship: FriendConnection?   // 👈 new addition
    
    @Relationship(deleteRule: .cascade)
    var stats: UserStats
        
    init(
        username: String,
        stats: UserStats,
        friendId: UUID = UUID(),
        avatar: String = "person.fill",
        id: UUID = UUID()
    ) {
        self.friendId = friendId
        self.username = username
        self.avatar = avatar
        self.id = id
        self.stats = stats
    }
}

struct FriendConnection: Codable {
    var senderId: UUID
    var receiverId: UUID
}

extension FriendConnection: Hashable {
    func hash(into hasher: inout Hasher) {
        let orderedPair = [senderId, receiverId].sorted { $0.uuidString < $1.uuidString }
        hasher.combine(orderedPair[0])
        hasher.combine(orderedPair[1])
    }

    static func ==(lhs: Self, rhs: Self) -> Bool {
        Set([lhs.senderId, lhs.receiverId]) == Set([rhs.senderId, rhs.receiverId])
    }
}
