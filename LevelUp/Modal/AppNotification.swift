//
//  AppNotification.swift
//  LevelUp
//
//  Created by Raúl Pichardo Avalo on 10/14/25.
//

import Foundation
import SwiftData


@Model
final class AppNotification: Identifiable {
    var id: UUID = UUID()
    
    var kind: Kind
    var sender: Friend?
    var receiverId: UUID?
    var payloadId: UUID?
    
    var status: StatusNotification
    var statusRaw: String
    
    var message: String?
    var isRead: Bool
    
    var lastTimeUpdated: Date = Date()
    var createdAt: Date = Date()
    
    init(kind: Kind, sender:  Friend? = nil, receiverId: UUID? = nil, status: StatusNotification = .pending, message: String? = nil, isRead: Bool = false, payloadId: UUID? = nil) {
        self.kind = kind
        self.sender = sender
        self.message = message
        self.status = status
        self.isRead = isRead
        self.payloadId = payloadId
        self.statusRaw = status.rawValue
        self.receiverId = receiverId
    }
}

// MARK: ACTIONS
extension AppNotification {
    
    enum Kind: String, Codable, Identifiable, CaseIterable {
        var id: UUID {
            UUID()
        }
        
        case friendRequest = "Friend Requests"
        case challenge = "Challenges"
        case system = "System"
        case preview = "Preview"
    }
    
    enum StatusNotification: String, Codable, Identifiable, CaseIterable {
        
        var id: UUID {
            UUID()
        }
        
        case pending, accepted, canceled, declined, expired
    }

    
    var title: String {
        kind.rawValue
    }
    
    var actionTitle: String {
        switch self.kind {
            case .friendRequest:
                return "Accept"
            case .challenge:
                return "Challenge"
        case .system, .preview:
                return "Open"
        }
    }
}

extension AppNotification {
    func updateStatus(to newStatus: StatusNotification) {
        self.status = newStatus
        self.statusRaw = newStatus.rawValue
        self.lastTimeUpdated = .now
    }
}
