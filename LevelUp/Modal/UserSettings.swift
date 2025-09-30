//
//  Settings.swift
//  LevelUp
//
//  Created by Raúl Pichardo Avalo on 9/10/25.
//

import Foundation
import SwiftData
import SwiftUI

@Model
final class UserSettings: Identifiable {
    var id: UUID
    var notificationsOn: Bool
    var theme: String
    
    var userId: UUID
    
    init(userId: UUID,
        notificationsOn: Bool = true,
        theme: String = "orange",
        id: UUID = UUID()
    ) {
        self.userId = userId
        self.notificationsOn = notificationsOn
        self.theme = theme
        self.id = id
    }
}

