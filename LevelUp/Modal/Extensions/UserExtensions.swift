//
//  UserExtensions.swift
//  LevelUp
//
//  Created by Raúl Pichardo Avalo on 9/29/25.
//

import Foundation
import SwiftData

// MARK: LOGS
extension User {
    /// Get or create a `ProgressLog` for a specific date (normalized to start of day)
    func log(for date: Date = Date()) -> ProgressLog {
        let key = Calendar.current.startOfDay(for: date)
        if let existing = progressLogs.first(where: { Calendar.current.isDate($0.date, inSameDayAs: key) }) {
            return existing
        } else {
            let newLog = ProgressLog(date: key)
            print("Added new log to the user progress log")
            progressLogs.append(newLog)
            return newLog
        }
    }
    
    @MainActor
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
        lastRefreshTrigger = Date() // ✅ forces SwiftUI to refresh computed values
    }

    /// Fetch events for a specific day
    func events(on date: Date) -> [ProgressEvent] {
        let key = Calendar.current.startOfDay(for: date)
        guard let log = progressLogs.first(where: { Calendar.current.isDate($0.date, inSameDayAs: key)} ) else {
            return []
        }
        return log.events
    }
    
    private func printEvents(on date: Date) {
        
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
}

// MARK: XP GAINED
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

// MARK: STREAK
extension User {
    func updateStreakIfNeeded() {
        let today = Calendar.current.startOfDay(for: Date())
        
        // Get all completed missions today
        let completedToday = events(on: today)
            .contains { $0.type == .completedMission }
        
        guard completedToday else { return } // only update if at least one mission done
        
        let calendar = Calendar.current
        if let lastDate = stats.lastStreakCompletedDate {
            let lastDay = calendar.startOfDay(for: lastDate)
            
            if calendar.isDateInToday(lastDay) {
                // Already updated today — no change
                return
            } else if let diff = calendar.dateComponents([.day], from: lastDay, to: today).day {
                if diff == 1 {
                    // Continued streak (yesterday → today)
                    stats.incrementStreakCount(forDate: today)
                } else {
                    // Missed a day → reset
                    stats.resetStreakCount()
                }
            }
        } else {
            // First completion ever
            stats.incrementStreakCount(forDate: today)
        }
    }
    
    func rebuildStreakFromLogs() {
        let calendar = Calendar.current

        // 1️⃣ Sort log dates in ascending order
        let sortedDates = progressLogs
            .map { calendar.startOfDay(for: $0.date) }
            .sorted()

        guard !sortedDates.isEmpty else {
            stats.resetStreakCount()
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
        
        self.stats.setStreakCount(currentStreak, forDate: previousDay)
    }
}

// MARK: RESET USERT
extension User {
    /// Completely reset the user's progress (keep account but reset XP and level).
    private func resetProgress(context: ModelContext) {
        do {
            print("Resetting user progress...")
            self.stats.reset()
            
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

// MARK: MISSIONS
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
