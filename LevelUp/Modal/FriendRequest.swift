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
    
    var from: Friend
    var to: UUID
    
    var fromRaw: String
    var receiverIdRaw: String
    
    var status: friendRequestStatus // "pending", "accepted"
    var createdAt: Date?
    
    var statusRaw: String
    var type: friendRequestStatus {
        get { friendRequestStatus(rawValue: statusRaw) ?? .pending }
        set { statusRaw = newValue.rawValue }
    }

    var id: UUID
    
    init(from: Friend, to: UUID, status: friendRequestStatus, createdAt: Date? = .now, id: UUID = UUID()) {
        self.from = from
        self.to = to
        self.status = status
        self.createdAt = createdAt
        self.id = id
        self.statusRaw = status.rawValue
        self.fromRaw = from.id.uuidString
        self.receiverIdRaw = to.uuidString
    }
}

enum friendRequestStatus: String, Codable {
    case pending
    case accepted
}

