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
}
