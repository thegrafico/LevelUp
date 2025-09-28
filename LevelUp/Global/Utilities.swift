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
            User.self,
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
            let descriptor = FetchDescriptor<User>()
            let users = try context.fetch(descriptor)

            if let first = users.first {
                return first
            } else {
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
    
    static func loadGlobalMissions(into context: ModelContext) async {
        do {
            let gloabalMissionType = MissionType.global.rawValue
            // 1. Fetch existing global missions
            let existing = try context.fetch(
                FetchDescriptor<Mission>(predicate: #Predicate { $0.typeRaw == gloabalMissionType })
            )

            // 2. Only insert if none exist
            if existing.isEmpty {
                for mission in Mission.sampleGlobalMissions {
                    print("Adding Global mission to CoreData: \(mission.title)")
                    context.insert(mission)
                }
                try context.save()
            } else {
                print("✅ Global missions already exist (\(existing.count))")
            }

        } catch {
            print("❌ Failed to load global missions: \(error)")
        }
    }
}
