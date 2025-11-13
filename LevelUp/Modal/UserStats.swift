//
//  UserStats.swift
//  LevelUp
//
//  Created by Raúl Pichardo Avalo on 10/14/25.
//

import Foundation
import SwiftData

@Model
final class UserStats: Identifiable {
    var level: Int
    var xp: Int
    var streakCount: Int
    var bestStreakCount: Int
    var lastStreakCompletedDate: Date?
    var challengeWonCount: Int
    var topMission: String?
    var missionCompletedCount: Int
    var lastActive: Date
    var id: UUID
    
    var isOnline: Bool  {
        lastActive.timeIntervalSinceNow.isLessThanOrEqualTo(60)
    }
    
    init(
        level: Int = 1,
        xp: Int = 0,
        streakCount: Int = 0,
        bestStreakCount: Int = 0,
        topMission: String? = nil,
        challengeWonCount: Int = 0,
        lastActive: Date = .now,
        missionCompletedCount: Int = 0,
        id: UUID = UUID()
    ) {
        self.level = level
        self.xp = xp
        self.streakCount = streakCount
        self.bestStreakCount = bestStreakCount
        self.topMission = topMission
        self.challengeWonCount = challengeWonCount
        self.lastActive = lastActive
        self.missionCompletedCount = missionCompletedCount
        self.id = id
    }
}


extension UserStats {
    
    func reset() {
        self.level = 1
        self.xp = 0
        self.streakCount = 0
        self.bestStreakCount = 0
        self.challengeWonCount = 0
        self.topMission = nil
    }
    
    func updateBestStreakCountIfNeeded() {
        if self.streakCount > self.bestStreakCount {
            self.bestStreakCount = self.streakCount
        }
    }
    
    func incrementStreakCount(forDate: Date? = nil) {
        self.streakCount += 1
        
        updateBestStreakCountIfNeeded()
        
        if let forDate = forDate {
            self.lastStreakCompletedDate = forDate
        }else {
            let today = Calendar.current.startOfDay(for: Date())
            self.lastStreakCompletedDate = today
        }
    }
    
    func setStreakCount(to count: Int, forDate: Date? = nil) {
        self.streakCount = count
        updateBestStreakCountIfNeeded()
        
        if let forDate = forDate {
            self.lastStreakCompletedDate = forDate
        }
    }
    
    func resetStreakCount() {
        self.streakCount = 0
        self.lastStreakCompletedDate = nil
    }
    
    func setLevel(_ level: Int) {
        self.level = level
    }
    
    
}

// MARK: XP
extension UserStats {
    
    func setXP(_ xp: Int) {
        self.xp = xp
    }
    
    // MARK: - add xp to user. return true if level up
    @discardableResult
    func addXP(_ amount: Int) -> Bool {
        self.xp += amount
        var didUserLevelUp = false

        // Loop in case we level up multiple times at once
        while xp >= requiredXP() {
            xp -= requiredXP() // carry over extra XP
            self.level += 1
            didUserLevelUp = true
        }
        
        return didUserLevelUp
    }
    
    // MARK: - Complete a mission. Return true if user level up
    @discardableResult
    func completeMission(_ mission: Mission) -> Bool {
        
        mission.markCompleted()
        
        let userDidLevelUp = addXP(mission.xp)
        
        self.missionCompletedCount += 1
        
        return userDidLevelUp
    }
    
    func requiredXP() -> Int {
        let baseXP = 100
        let increment = 25
        return baseXP + (self.level - 1) * increment
    }
}

extension User {
    
    func updateStreakIfNeeded() {
        print("Updating streak if needed")
        let today = Calendar.current.startOfDay(for: Date())
        
        // Get all completed missions today
        let completedToday = events(on: today)
            .contains { $0.type == .completedMission }
        
        guard completedToday else { return } // only update if at least one mission done
        
        print("Incrementing...")
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
                    stats.setStreakCount(to: 1, forDate: today)
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
            stats.setStreakCount(to: 0)
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
        
        self.stats.setStreakCount(to: currentStreak, forDate: previousDay)
    }
}
