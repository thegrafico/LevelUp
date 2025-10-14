//
//  AppNotification.swift
//  LevelUp
//
//  Created by Raúl Pichardo Avalo on 10/14/25.
//

import Foundation

struct AppNotification: Identifiable {
    
    enum Kind: String, CaseIterable {
        case friendRequest = "Friend Requests"
        case challenge = "Challenges"
        case system = "System"
    }

    var id: UUID = UUID()
    var title: String {
        kind.rawValue
    }
    var kind: Kind
    var message: String?
    var sender: Friend?
    var isRead: Bool = false
    
    var payload: Any?
}

// MARK: ACTIONS
extension AppNotification {
    
    var actionTitle: String {
        switch self.kind {
            case .friendRequest:
                return "Accept"
            case .challenge:
                return "Challenge"
            case .system:
                return "Open"
        }
    }
}
