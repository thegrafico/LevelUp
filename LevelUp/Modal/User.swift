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
}


// MARK: - Sample Friends
extension Friend {
    static let sampleFriends: [Friend] = [
        .init(username: "Liam", avatar: "person.crop.circle.fill"),
        .init(username: "Maya", avatar: "person.circle.fill")
    ]
}


// MARK: - Add relationships
extension User {
    static func sampleUser() -> User {
        let user = User(
            username: "TestUser",
            passwordHash: "hash123",
            email: "test@demo.com",
            level: 1,
            xp: 10,
        )
        user.missions = []
        user.friends = Friend.sampleFriends
        return user
    }
}


// TODO: firts level start at 100xp, then it will be adding 25xp to the base for upgrading the current level.
extension User {
    /// XP required to reach the next level.
    func requiredXP() -> Int {
        let baseXP = 100
        let increment = 25
        return baseXP + (level - 1) * increment
    }
}


extension User {
    static var LIMIT_POINTS_PER_DAY : Double = 150
}

extension User {
    /// Adds XP to the user and updates their level if needed.
    func addXP(_ amount: Int) {
        xp += amount

        // Loop in case we level up multiple times at once
        while xp >= requiredXP() {
            xp -= requiredXP() // carry over extra XP
            level += 1
        }
    }
    
    /// XP progress as a percentage toward next level.
    var progressToNextLevel: Double {
        Double(xp) / Double(requiredXP())
    }
}

//// MARK: - Sample Users
//extension User {
//    static let sampleData: [User] = [
//        .init(
//            username: "Alex",
//            passwordHash: "test",
//            email: "test@test.com",
//            avatar: "person.fill",
//            level: 1,
//            xp: 0,
//            settings: UserSettings(),
//            id: UUID()
//        ),
//        .init(
//            username: "Raul",
//            passwordHash: "test2",
//            email: "test2@test.com",
//            avatar: "person.fill",
//            level: 3,
//            xp: 45,
//            settings: UserSettings(),
//            id: UUID()
//        )
//    ]
//}
