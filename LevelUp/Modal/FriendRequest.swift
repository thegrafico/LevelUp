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
    
    var statusRaw: String
    var status: AppNotification.StatusNotification {
        get { AppNotification.StatusNotification(rawValue: statusRaw) ?? .pending}
        set { statusRaw = newValue.rawValue }
    }
    
    var createdAt: Date?
    var id: UUID
    
    init(from: Friend, to: Friend, status: AppNotification.StatusNotification, createdAt: Date? = .now, id: UUID = UUID()) {
        self.from = from
        self.to = to
        self.createdAt = createdAt
        self.id = id
        self.statusRaw = status.rawValue
    }
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
    
    func updateStatus(to: AppNotification.StatusNotification) {
        self.statusRaw = to.rawValue
    }
}

extension Sequence where Element == FriendRequest {
    func asNotifications() -> [AppNotification] {
        map { $0.asNotification() }
    }
}

