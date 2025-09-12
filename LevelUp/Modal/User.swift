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
    @Attribute(.unique) var id: UUID
    
    var username: String
    var passwordHash: String
    var email: String

    var level: Int
    var xp: Int
    
    var avatar: String?
    
    // When a user is deleted, all its reletionship gets deleted as well
    @Relationship(deleteRule: .cascade) var missions: [Mission] = []
    @Relationship(deleteRule: .cascade) var friends: [Friend] = []
    @Relationship(deleteRule: .cascade) var settings: UserSettings?
    
    init(
        username: String,
        passwordHash: String,
        email: String,
        avatar: String = "person.fill",
        level: Int = 1,
        xp: Int = 0,
        settings: UserSettings? = UserSettings(),
        id: UUID = UUID()
    ) {
        self.username = username
        self.passwordHash = passwordHash
        self.email = email
        self.avatar = avatar
        self.level = level
        self.xp = xp
        self.settings = settings
        self.id = id
    }
    
    
    static let sampleData: [User] = [
        .init(username: "Alex", passwordHash: "test", email: "test@test.com")
    ]
}
