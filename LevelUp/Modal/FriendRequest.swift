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
    var to: Friend
    
    var status: friendRequestStatus // "pending", "accepted"
    var createdAt: Date?
    
    var statusRaw: String
    var type: friendRequestStatus {
        get { friendRequestStatus(rawValue: statusRaw) ?? .pending }
        set { statusRaw = newValue.rawValue }
    }

    var id: UUID
    
    init(from: Friend, to: Friend, status: friendRequestStatus, createdAt: Date? = .now, id: UUID = UUID()) {
        self.from = from
        self.to = to
        self.status = status
        self.createdAt = createdAt
        self.id = id
        self.statusRaw = status.rawValue
    }
}

enum friendRequestStatus: String, Codable {
    case pending
    case accepted
}

extension FriendRequest {
    
    func asNotification() -> AppNotification {
            // Custom, related messages for friend requests
            let messages = [
                "sent you a friend request!",
                "wants to connect with you.",
                "thinks you’d make a great teammate!",
                "believes you can compete together.",
                "just discovered your profile 👀",
                "challenged you to become friends!"
            ]
            
            let randomMessage = messages.randomElement() ?? "sent you a friend request!"
            
            return AppNotification(
                kind: .friendRequest,
                sender: from,
                receiverId: to.friendId,
                message: randomMessage,
                payloadId: id
            )
        }
}

extension Sequence where Element == FriendRequest {
    func asNotifications() -> [AppNotification] {
        map { $0.asNotification() }
    }
}

