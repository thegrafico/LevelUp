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
    var isFavorite: Bool
    
    var stats: UserStats
        
    init(
        username: String,
        stats: UserStats,
        friendId: UUID = UUID(),
        relationshipFriendId: UUID? = nil,
        isFavorite: Bool = false,
        avatar: String = "person.fill",
        id: UUID = UUID(),
    ) {
        self.friendId = friendId
        self.username = username
        self.avatar = avatar
        self.id = id
        self.stats = stats
        self.relationshipFriendId = relationshipFriendId
        self.isFavorite = false
    }
}
