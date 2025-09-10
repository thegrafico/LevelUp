//
//  Settings.swift
//  LevelUp
//
//  Created by Raúl Pichardo Avalo on 9/10/25.
//

import Foundation
import SwiftData

@Model
final class Settings: Identifiable {
    @Attribute(.unique) var id: UUID
    var notificationsOn: Bool
    var darkModeOn: Bool
    var theme: String
    
    var user: User?   // inverse relationship
    
    init(
        id: UUID = UUID(),
        notificationsOn: Bool = true,
        darkModeOn: Bool = false,
        theme: String = "orange"
    ) {
        self.id = id
        self.notificationsOn = notificationsOn
        self.darkModeOn = darkModeOn
        self.theme = theme
    }
}

