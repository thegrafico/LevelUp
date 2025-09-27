//
//  FriendRequest.swift
//  LevelUp
//
//  Created by Raúl Pichardo Avalo on 9/26/25.
//

import Foundation
import SwiftData


@Model
final class FriendRequest: Identifiable {
    var from: User
    var to: User
    var status: friendRequestStatus // "pending", "accepted"
    var createdAt: Date?
    
    var id: UUID
    
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

