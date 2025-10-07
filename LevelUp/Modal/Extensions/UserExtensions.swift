//
//  UserExtensions.swift
//  LevelUp
//
//  Created by Raúl Pichardo Avalo on 9/29/25.
//

import Foundation
import SwiftData

extension User {
    /// XP required to reach the next level.
    func requiredXP() -> Int {
        let baseXP = 100
        let increment = 25
        return baseXP + (level - 1) * increment
    }
    
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

// MARK: STATIC Var/Func
extension User {
    
    static var LIMIT_POINTS_PER_DAY : Double = 100
    
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
}

// MARK: - Sample Data for Testing
extension User {
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


extension User {
    /// Get or create a `ProgressLog` for a specific date (normalized to start of day)
    func log(for date: Date = Date()) -> ProgressLog {
        let key = Calendar.current.startOfDay(for: date)
        if let existing = progressLogs.first(where: { Calendar.current.isDate($0.date, inSameDayAs: key) }) {
            return existing
        } else {
            let newLog = ProgressLog(date: key)
            progressLogs.append(newLog)
            return newLog
        }
    }

    /// Add an event to a day's log (default: today)
    func logEvent(
        _ type: ProgressEventType,
        mission: Mission? = nil,
        level: Int? = nil,
        details: String? = nil
    ) {
        let logEntry = log(for: Date())
        let event = ProgressEvent(
            type: type,
            missionId: mission?.id,
            missionTitle: mission?.title,
            missionXP: mission?.xp,
            missionType: mission?.type,
            missionCompletionTime: mission?.completionDate,
            userLevel: level,
            details: details
        )
        logEntry.events.append(event)
    }

    /// Fetch events for a specific day
    func events(on date: Date) -> [ProgressEvent] {
        let key = Calendar.current.startOfDay(for: date)
        guard let log = progressLogs.first(where: { Calendar.current.isDate($0.date, inSameDayAs: key)} ) else {
            return []
        }
        return log.events
    }
    
    func printEvents(on date: Date) {
        
        for event in events(on: date) {
            
            switch event.type {
            case .completedMission:
                print("Event For Completed Missions: \(event.missionTitle ?? "Unknown")")
                print("ID: \(String(describing: event.missionId))")
                print("XP: \(event.missionXP ?? 0)")
                print("Type: \(event.missionType ?? "")")
                print("Completion Time: \(String(describing:event.missionCompletionTime))")
            case .addMission:
                print("Event For Adding Missions: \(event.missionTitle ?? "Unknown")")
                print("ID: \(String(describing: event.missionId))")
                print("XP: \(event.missionXP ?? 0)")
                print("Type: \(event.missionType ?? "")")
                print("Completion Time: \(String(describing:event.missionCompletionTime))")
            case .deleteMission:
                print("Event For Deleting a Missions: \(event.missionTitle ?? "Unknown")")
                print("ID: \(String(describing: event.missionId))")
                print("XP: \(event.missionXP ?? 0)")
                print("Type: \(event.missionType ?? "")")
                print("DeletionTime: \(String(describing:event.date))")
            case .editedMission:
                print("Event For Editing a Mission: \(event.missionTitle ?? "Unknown")")
                print("ID: \(String(describing: event.missionId))")
                print("XP: \(event.missionXP ?? 0)")
                print("Type: \(event.missionType ?? "")")
                print("Edited Time: \(String(describing:event.date))")
            case .friendAdded:
                print("Events for adding a friend.")
            case .userLevelUp:
                print("Events for user leveling Up")
                print("Level: \(String(describing: event.userLevel))")
            }
        }
    }

    /// A grouped dictionary: date → [events]
    var eventsGroupedByDay: [Date: [ProgressEvent]] {
        var dict = [Date: [ProgressEvent]]()
        for log in progressLogs {
            let dayKey = Calendar.current.startOfDay(for: log.date)
            dict[dayKey, default: []] += log.events
        }
        return dict
    }

    /// Optionally as string-keyed dictionary (e.g. "YYYY-MM-dd")
    var eventsGroupedByString: [String: [ProgressEvent]] {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        var dict = [String: [ProgressEvent]]()
        for log in progressLogs {
            let key = formatter.string(from: log.date)
            dict[key, default: []] += log.events
        }
        return dict
    }
    
    
    
    var xpGainedToday: Double {
        let completedEvents = events(on: Date())
            .filter { $0.type == .completedMission }

        return Double(
            completedEvents.reduce(0) { sum, event in
                sum + (event.missionXP ?? 0)
            }
        )
    }
    
    var clampedXpToday: Double {
        min(max(xpGainedToday, 0), User.LIMIT_POINTS_PER_DAY)
    }
}

extension User {
    /// Completely reset the user's progress (keep account but reset XP and level).
    private func resetProgress(context: ModelContext) {
        do {
            print("Resetting user progress...")
            self.level = 1
            self.xp = 0
            
            for log in progressLogs {
                context.delete(log)
            }
            progressLogs.removeAll()

            for mission in missions {
                mission.markIncomplete()
                context.delete(mission)
            }
            missions.removeAll()

            for friend in friends {
                context.delete(friend)
            }
            friends.removeAll()
            
            try context.save()
            
            for mission in missions {
                mission.printMission()
            }
            print("Done resetting user progress.")
        } catch {
            print("Failed to reset user progress: \(error)")
        }
        
    }

    /// Delete all data tied to this user (missions, friends, logs, settings).
    /// Typically you’d call this through the model context.
    func deleteAllData(context: ModelContext){
        print("Deleting user data...")
        resetProgress(context: context)
    }
    
}

extension User {
    /// XP gained in the last 7 days
    var xpGainedThisWeek: Double {
        guard let startOfWeek = Calendar.current.date(
            from: Calendar.current.dateComponents([.yearForWeekOfYear, .weekOfYear], from: Date())
        ) else { return 0 }

        // Filter logs from the last 7 days
        let recentLogs = progressLogs.filter { $0.date >= startOfWeek }

        // Flatten events and filter completed missions
        let completedEvents = recentLogs
            .flatMap { $0.events }
            .filter { $0.type == .completedMission }

        // Sum XP values
        let totalXP = completedEvents.reduce(0) { sum, event in
            sum + (event.missionXP ?? 0)
        }

        return Double(totalXP)
    }

    /// Total XP gained overall
    var xpGainedTotal: Double {
        let allEvents = progressLogs.flatMap { $0.events }
        let completed = allEvents.filter { $0.type == .completedMission }
        let totalXP = completed.reduce(0) { sum, event in
            sum + (event.missionXP ?? 0)
        }
        return Double(totalXP)
    }
}


extension User {
    func updateStreakIfNeeded() {
        let today = Calendar.current.startOfDay(for: Date())

        // Get all completed missions today
        let completedToday = events(on: today)
            .contains { $0.type == .completedMission }

        guard completedToday else { return } // only update if at least one mission done

        let calendar = Calendar.current
        if let lastDate = lastStreakCompletedDate {
            let lastDay = calendar.startOfDay(for: lastDate)

            if calendar.isDateInToday(lastDay) {
                // Already updated today — no change
                return
            } else if let diff = calendar.dateComponents([.day], from: lastDay, to: today).day {
                if diff == 1 {
                    // Continued streak (yesterday → today)
                    streakCount += 1
                } else {
                    // Missed a day → reset
                    streakCount = 1
                }
            }
        } else {
            // First completion ever
            streakCount = 1
        }

        lastStreakCompletedDate = today
    }
    
    func rebuildStreakFromLogs() {
        let calendar = Calendar.current

        // 1️⃣ Sort log dates in ascending order
        let sortedDates = progressLogs
            .map { calendar.startOfDay(for: $0.date) }
            .sorted()

        guard !sortedDates.isEmpty else {
            streakCount = 0
            lastStreakCompletedDate = nil
            return
        }

        var currentStreak = 0
        var previousDay: Date? = nil

        for day in sortedDates {
            // Check if this log actually has at least one completed mission
            let hasCompleted = progressLogs
                .first(where: { calendar.isDate($0.date, inSameDayAs: day) })?
                .events
                .contains(where: { $0.type == .completedMission }) ?? false

            guard hasCompleted else { continue }

            if let prev = previousDay {
                let diff = calendar.dateComponents([.day], from: prev, to: day).day ?? 0

                if diff == 1 {
                    currentStreak += 1
                } else {
                    currentStreak = 1
                }
            } else {
                currentStreak = 1
            }

            previousDay = day
        }

        streakCount = currentStreak
        lastStreakCompletedDate = previousDay
    }
}
