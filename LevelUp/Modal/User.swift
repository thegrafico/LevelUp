//
//  User.swift
//  LevelUp
//
//  Created by Raúl Pichardo Avalo on 9/10/25.
//

import Foundation
import SwiftData

@Model
final class User: Identifiable {
    var id: UUID
    var username: String
    var passwordHash: String
    var email: String

    var level: Int
    var xp: Int
    var avatar: String?
    
    var lastRefreshTrigger: Date = Date()

    @Relationship(deleteRule: .cascade)
    var missions: [Mission] = []
    @Relationship(deleteRule: .cascade)
    var friends: [Friend] = []
    @Relationship(deleteRule: .cascade)
    var progressLogs: [ProgressLog] = []
    @Relationship(deleteRule: .cascade)
    var settings: UserSettings
    init(
        username: String,
        passwordHash: String,
        email: String,
        avatar: String = "person.fill",
        level: Int = 1,
        xp: Int = 0,
        id: UUID = UUID()
    ) {
        self.id = id
        self.username = username
        self.passwordHash = passwordHash
        self.email = email
        self.avatar = avatar
        self.level = level
        self.xp = xp
        self.settings = UserSettings(userId: id)
    }
}


extension User {
    var globalMissions: [Mission] {
        missions.filter { $0.isGlobal }
    }
    
    var customMissions: [Mission] {
        missions.filter { $0.isCustom }
    }
    
    var activeMissions: [Mission] {
        missions.filter { !$0.isDisabledToday }
    }
    
    var completedMissions: [Mission] {
        missions.filter { $0.isDisabledToday }
    }
    
    var allMissions: [Mission] {
        globalMissions + customMissions
    }
}
