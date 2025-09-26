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
    @Attribute(.unique) var id: UUID
    var username: String
    var avatar: String
    var xp: Int
    
    var user: User?   // inverse relationship
    
    init(
        username: String,
        avatar: String = "person.fill",
        xp: Int = 0,
        id: UUID = UUID()
    ) {
        self.username = username
        self.avatar = avatar
        self.xp = xp
        self.id = id
    }
}


@Model
final class FriendRequest: Identifiable {
    var from: User
    var to: User
    var status: friendRequestStatus // "pending", "accepted"
    var createdAt: Date?
    
    @Attribute(.unique) var id: UUID
    
    init(from: User, to: User, status: friendRequestStatus, createdAt: Date? = .now, id: UUID = UUID()) {
        self.from = from
        self.to = to
        self.status = status
        self.createdAt = createdAt
        self.id = id
    }
}

enum friendRequestStatus: String, Codable {
    case pending
    case accepted
}
