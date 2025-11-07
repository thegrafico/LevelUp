//
//  MissionRequest.swift
//  LevelUp
//
//  Created by Raúl Pichardo Avalo on 11/2/25.
//

import Foundation
import SwiftData


@Model
final class MissionRequest: Identifiable {
    
    var from: Friend
    var to: Friend
    var mission: Mission
    
    var statusRaw: String
    var status: AppNotification.StatusNotification {
        get { AppNotification.StatusNotification(rawValue: statusRaw) ?? .pending}
        set { statusRaw = newValue.rawValue }
    }
    
    var createdAt: Date?
    var lastTimeUpdated: Date?
    var id: UUID
    
    init(from: Friend, to: Friend, mission: Mission,  status: AppNotification.StatusNotification, id: UUID = UUID()) {
        self.from = from
        self.to = to
        self.mission = mission
        self.id = id
        self.statusRaw = status.rawValue
        
        self.createdAt = Date()
        self.lastTimeUpdated = Date()
    }
}


extension MissionRequest {
    
    func asNotification() -> AppNotification {
            // Custom, related messages for friend requests
            let messages = [
                "sent you a mission!",
                "Someone thinks you can get this done",
                "Do you accept the challenge?",
                "Thinks this can be good for you!"
            ]
            
            let randomMessage = messages.randomElement() ?? "Sent you a mission!"
            
            return AppNotification(
                kind: .missionRequest,
                sender: from,
                receiverId: to.friendId,
                message: randomMessage,
                payloadId: id
            )
        }
    
    
    func updateStatus(to: AppNotification.StatusNotification) {
        self.statusRaw = to.rawValue
        self.lastTimeUpdated = .now
    }
    
    func updateMission(with newMission: Mission) {
        self.mission = newMission
        self.lastTimeUpdated = .now
    }
    
    func belogsToUser(withId userId: UUID) -> Bool {
        from.friendId == userId || to.friendId == userId
    }
}

extension Sequence where Element == MissionRequest {
    func asNotifications() -> [AppNotification] {
        map { $0.asNotification() }
    }
}

