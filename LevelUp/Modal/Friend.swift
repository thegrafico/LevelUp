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
    var friendId: UUID // id of the friend
    var relationshipFriendId: UUID? // id of the other friend
    var username: String
    var avatar: String
    
    @Relationship(deleteRule: .cascade)
    var stats: UserStats
        
    init(
        username: String,
        stats: UserStats,
        friendId: UUID = UUID(),
        relationshipFriendId: UUID? = nil,
        avatar: String = "person.fill",
        id: UUID = UUID(),
    ) {
        self.friendId = friendId
        self.username = username
        self.avatar = avatar
        self.id = id
        self.stats = stats
        self.relationshipFriendId = relationshipFriendId
    }
}
