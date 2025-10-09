//
//  Utilities.swift
//  LevelUp
//
//  Created by Raúl Pichardo Avalo on 9/28/25.
//

import Foundation
import SwiftData

@MainActor
enum DataSeeder {
    
    // Clear all data from all models
    static func clearAll(from context: ModelContext) throws {
        let entities: [any PersistentModel.Type] = [
//            User.self,
            Mission.self,
            Friend.self,
            FriendRequest.self,
            ProgressLog.self,
            UserSettings.self
        ]
        
        for entity in entities {
            try context.delete(model: entity) // <-- batch delete
        }
        
        try context.save()
        print("🧹 Cleared all data.")
    }
    
    // Insert dummy data
    static func insertDummyData(into context: ModelContext) throws -> User {
        let user = User.sampleUser()
        context.insert(user)
        
        // Add sample missions
        for mission in Mission.sampleData {
            context.insert(mission)
            user.missions.append(mission)
        }
        
        // Add global missions only if none exist
        let existingGlobals = try context.fetch(FetchDescriptor<Mission>())
            .filter { $0.isGlobal }
        if existingGlobals.isEmpty {
            for mission in Mission.sampleGlobalMissions {
                context.insert(mission)
            }
        }
        
        // Add friends
        for friend in Friend.sampleFriends {
            context.insert(friend)
            user.friends.append(friend)
        }
        
        try context.save()
        print("✨ Inserted dummy data: \(user.username)")
        return user
    }
    
    static func loadUserIfNeeded(into context: ModelContext) async -> User? {
        do {
            print("Loading user from swift data...")
            let descriptor = FetchDescriptor<User>()
            let users = try context.fetch(descriptor)

            if let first = users.first {
                print("Found user: \(first.username)")
                return first
            } else {
                print("User not found, using sample user.")
                let newUser = User.sampleUser()
                context.insert(newUser)
                
                try context.save()
                return newUser
            }
        } catch {
            print("❌ Failed to load user: \(error)")
        }
        
        return nil
    }
    
    
    static func loadGlobalMissions(for user: User, in context: ModelContext) async {
        do {
            let globalMissionType = MissionType.global.rawValue

            // 1. Check if the user already has global missions
            let existing = user.missions.filter { $0.typeRaw == globalMissionType }

            // 2. Only insert if none exist
            if existing.isEmpty {
                for mission in Mission.sampleGlobalMissions {
                    print("Adding Global mission to user: \(mission.title)")
//                    mission.printMission()
                    context.insert(mission)
                    user.missions.append(mission)  // ✅ attach to the user
                }
                try context.save()
            } else {
                print("✅ User already has global missions (\(existing.count))")
            }

        } catch {
            print("❌ Failed to load global missions: \(error)")
        }
    }
    
    static func loadLocalMissions(for user: User, in context: ModelContext) async {
        do {
            let localMissions = MissionType.custom.rawValue

            // 1. Check if the user already has global missions
            let existing = user.missions.filter { $0.typeRaw == localMissions }

            // 2. Only insert if none exist
            if existing.isEmpty {
                for mission in Mission.SampleLocalMissions {
                    print("Adding Local mission to user: \(mission.title)")
                    context.insert(mission)
                    user.missions.append(mission)
                }
                try context.save()
            } else {
                print("✅ User already has local missions (\(existing.count))")
            }

        } catch {
            print("❌ Failed to load local missions: \(error)")
        }
    }
    
    // MARK: - Add Progress Logs for a User
    static func addSampleLogs(for user: User, in context: ModelContext) async {
        let calendar = Calendar.current
        let now = Date()
        let yesterday = calendar.date(byAdding: .day, value: -1, to: now)!

        // --- Use the user's missions as base
        let baseMissions = user.missions
        guard !baseMissions.isEmpty else {
            print("⚠️ No missions found for user. Logs not created.")
            return
        }

        // --- Create logs for the past 7 days
        let daysRange = (-6...0).compactMap { calendar.date(byAdding: .day, value: $0, to: yesterday) }

        for day in daysRange {
            let log = ProgressLog(date: calendar.startOfDay(for: day))

            // Randomize number of completed missions per day
            let missionCount = Int.random(in: 3...12)
            let dailyMissions = (0..<missionCount).compactMap { _ in baseMissions.randomElement() }

            for mission in dailyMissions {
                let randomHour = Int.random(in: 7...22)
                let randomMinute = Int.random(in: 0...59)
                let completionDate = calendar.date(
                    bySettingHour: randomHour,
                    minute: randomMinute,
                    second: 0,
                    of: day
                )!

                let event = ProgressEvent(
                    type: .completedMission,
                    missionId: mission.id,
                    missionTitle: mission.title,
                    missionXP: mission.xp + Int.random(in: -5...10),
                    missionType: mission.type,
                    missionCompletionTime: completionDate,
                    userLevel: user.level,
                    details: "Completed mission: \(mission.title)"
                )

                log.events.append(event)
            }

            log.events.sort {
                ($0.missionCompletionTime ?? .distantPast) <
                ($1.missionCompletionTime ?? .distantPast)
            }

            user.progressLogs.append(log)
            context.insert(log)
        }

        // --- Update XP and level based on total
        let totalXP = user.progressLogs
            .flatMap { $0.events }
            .reduce(0) { $0 + ($1.missionXP ?? 0) }

        user.xp = totalXP / 4
        user.level = 1 + (totalXP / 500)

        do {
            try context.save()
            print("📊 Added sample logs for user \(user.username). XP: \(user.xp), Level: \(user.level)")
        } catch {
            print("❌ Failed to add logs: \(error)")
        }
    }
}
