//
//  Settings.swift
//  LevelUp
//
//  Created by Raúl Pichardo Avalo on 9/10/25.
//

import Foundation
import SwiftData

@Model
final class UserSettings: Identifiable {
    @Attribute(.unique) var id: UUID
    var notificationsOn: Bool
    var darkModeOn: Bool
    var theme: String
    
    var user: User?   // inverse relationship
    
    init(
        notificationsOn: Bool = true,
        darkModeOn: Bool = false,
        theme: String = "orange",
        id: UUID = UUID()
    ) {
        self.notificationsOn = notificationsOn
        self.darkModeOn = darkModeOn
        self.theme = theme
        self.id = id
    }
}

