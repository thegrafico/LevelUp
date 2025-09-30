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
    
        return Double(events(on: Date()).reduce(0) { sum, event in
            sum + (event.missionXP ?? 0)
        })
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
