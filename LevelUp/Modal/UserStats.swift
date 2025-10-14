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
        id: UUID = UUID()
    ) {
        self.level = level
        self.xp = xp
        self.streakCount = streakCount
        self.bestStreakCount = bestStreakCount
        self.topMission = topMission
        self.challengeWonCount = challengeWonCount
        self.lastActive = lastActive
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
    
    func incrementStreakCount(forDate: Date? = nil) {
        self.streakCount += 1
        
        if let forDate = forDate {
            self.lastStreakCompletedDate = forDate
        }else {
            let today = Calendar.current.startOfDay(for: Date())
            self.lastStreakCompletedDate = today
        }
    }
    
    func setStreakCount(_ count: Int, forDate: Date? = nil) {
        self.streakCount = count
        
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
    
    func addXP(_ amount: Int) {
        self.xp += amount

        // Loop in case we level up multiple times at once
        while xp >= requiredXP() {
            xp -= requiredXP() // carry over extra XP
            self.level += 1
        }
    }
    
    func requiredXP() -> Int {
        let baseXP = 100
        let increment = 25
        return baseXP + (self.level - 1) * increment
    }
}

