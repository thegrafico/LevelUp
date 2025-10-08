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
    
    var streakCount: Int = 0
    var lastStreakCompletedDate: Date? = nil
    
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

// MARK: STATIC VARS
extension User {
    static var LIMIT_POINTS_PER_DAY : Double = 100
}

// MARK: - Sample Data for Testing
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
        user.friends = []
        return user
    }
    
    static func sampleUserWithMissions() -> User {
        let user = User(
            username: "TestUser",
            passwordHash: "hash123",
            email: "test@demo.com",
            level: 1,
            xp: 10,
        )
        user.missions = [
            Mission(title: "Morning Run", xp: 30, type: .global, icon: "figure.run"),
            Mission(title: "Read a Chapter", xp: 20, type: .global, icon: "book.fill")
        ]
        user.friends = []
        return user
    }
    
    static func sampleUserWithLogs() -> User {
        let user = User(
            username: "RaúlTest",
            passwordHash: "hash123",
            email: "raul@test.com",
            level: 4,
            xp: 60
        )

        let calendar = Calendar.current
        let now = Date()
//        let yesterday = calendar.date(byAdding: .day, value: -1, to: now)!

        // --- Create sample missions with icons ---
        let baseMissions: [Mission] = [
            Mission(title: "Morning Run", xp: 30, type: .global, icon: "figure.run"),
            Mission(title: "Read a Chapter", xp: 20, type: .global, icon: "book.fill"),
            Mission(title: "Cook a Meal", xp: 40, type: .global, icon: "fork.knife"),
            Mission(title: "Clean Desk", xp: 15, type: .custom, icon: "deskview.fill"),
            Mission(title: "Meditate", xp: 25, type: .custom, icon: "brain.head.profile"),
            Mission(title: "Push-up Challenge", xp: 35, type: .global, icon: "bolt.fill"),
            Mission(title: "Water Plants", xp: 10, type: .custom, icon: "leaf.fill"),
            Mission(title: "Call a Friend", xp: 15, type: .global, icon: "phone.fill"),
            Mission(title: "Finish a Task", xp: 20, type: .custom, icon: "checkmark.seal.fill"),
            Mission(title: "Stretch", xp: 10, type: .custom, icon: "figure.cooldown"),
            Mission(title: "Write Journal", xp: 20, type: .custom, icon: "pencil.and.scribble"),
            Mission(title: "Listen to Podcast", xp: 25, type: .global, icon: "headphones"),
            Mission(title: "Evening Walk", xp: 30, type: .global, icon: "figure.walk.motion"),
            Mission(title: "Plan Tomorrow", xp: 15, type: .custom, icon: "calendar.badge.clock"),
            Mission(title: "Do Laundry", xp: 10, type: .custom, icon: "washer.fill"),
            Mission(title: "Learn Something New", xp: 50, type: .global, icon: "lightbulb.fill")
        ]

        user.missions.append(contentsOf: baseMissions)

        // --- Create progress logs for the past 7 days ---
        let daysRange = (-6...0).compactMap { calendar.date(byAdding: .day, value: $0, to: now) }

        for day in daysRange {
            let log = ProgressLog(date: calendar.startOfDay(for: day))

            // ✅ Randomize number of missions per day
            let missionCount = Int.random(in: 3...15)
            let dailyMissions = (0..<missionCount).compactMap { _ in baseMissions.randomElement() }

            for mission in dailyMissions {
                // ✅ Random time between 7 AM – 10 PM
                let randomHour = Int.random(in: 7...22)
                let randomMinute = Int.random(in: 0...59)
                let completionDate = calendar.date(
                    bySettingHour: randomHour,
                    minute: randomMinute,
                    second: 0,
                    of: day
                )!

                mission.completionDate = completionDate
                mission.completed = true

                let event = ProgressEvent(
                    type: .completedMission,
                    missionId: mission.id,
                    missionTitle: mission.title,
                    missionXP: mission.xp + Int.random(in: -5...10), // small XP variance
                    missionType: mission.type,
                    missionCompletionTime: completionDate,
                    userLevel: user.level,
                    details: "Completed successfully"
                )

                log.events.append(event)
            }

            // Sort events by time for realism
            log.events.sort {
                ($0.missionCompletionTime ?? .distantPast) <
                ($1.missionCompletionTime ?? .distantPast)
            }

            user.progressLogs.append(log)
        }

        // --- Simulate XP & Level ---
        let totalXP = user.progressLogs
            .flatMap { $0.events }
            .reduce(0) { $0 + ($1.missionXP ?? 0) }

        user.xp = totalXP / 4
        user.level = 1 + (totalXP / 500)

        return user
    }
}
