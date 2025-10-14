//
//  SampleData.swift
//  LevelUp
//
//  Created by Raúl Pichardo Avalo on 9/25/25.
//

import Foundation
import SwiftData

@MainActor
class SampleData {
    static let shared = SampleData()
    
    let modelContainer: ModelContainer
    
    var context: ModelContext {
        modelContainer.mainContext
    }
    
    private init() {
        let schema = Schema([
            User.self,
            Mission.self,
            Friend.self,
            FriendRequest.self,
            ProgressLog.self,
            UserSettings.self
        ])
        
        let configuration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: true // ✅ keeps this Preview-only
        )
        
        do {
            modelContainer = try ModelContainer(
                for: schema,
                configurations: [configuration]
            )
            
            insertSampleUsers()
            try context.save()
            
        } catch {
            fatalError("❌ Unable to create Sample Model Container: \(error)")
        }
    }
    
    func insertSampleUsers() {
           print("📦 Inserting sample users with missions and progress...")
           
           let missions = Mission.sampleData
           let stats = UserStats(level: 3, xp: 240)
           
           // 👤 Create 2 demo users
           let user1 = User(
               username: "Raul",
               passwordHash: "hash1",
               email: "raul@demo.com",
               stats: stats
           )
           
           let user2 = User(
               username: "SwiftMaster",
               passwordHash: "hash2",
               email: "swift@demo.com",
               stats: UserStats(level: 2, xp: 120)
           )
           
           // ✅ Assign some missions
           user1.missions = Array(missions.prefix(3))
           user2.missions = Array(missions.suffix(3))
           
           // ✅ Connect them as friends
           let friend1 = Friend(username: user2.username, stats: user2.stats)
           let friend2 = Friend(username: user1.username, stats: user1.stats)
           user1.friends = [friend1]
           user2.friends = [friend2]
           
           // ✅ Insert into context
           context.insert(user1)
           context.insert(user2)
           
           print("✅ Inserted users: \(user1.username), \(user2.username)")
       }
    
    private func insertSampleMissions() {
        // Insert sample missions
        print("Inserting sample missions")
        for mission in (Mission.sampleData + Mission.sampleGlobalMissions) {
            print("Mission: \(mission.title), With Type: \(mission.type.rawValue)")
            context.insert(mission)
        }
        print("Done.")

    }
}


@MainActor
enum PreviewContainer {
    static var missions: ModelContainer = {
        do {
            let schema = Schema([Mission.self]) // only include what you need for the preview
            let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
            let container = try ModelContainer(for: schema, configurations: [configuration])
            
            // Preload sample missions
            let context = container.mainContext
            Mission.sampleGlobalMissions.forEach { context.insert($0) }
            
            try? context.save()
            return container
        } catch {
            fatalError("❌ Failed to create PreviewContainer: \(error)")
        }
    }()
}
//
//static func sampleUser() -> User {
//    let user = User(
//        username: "TestUser",
//        passwordHash: "hash123",
//        email: "test@demo.com",
//        level: 1,
//        xp: 10,
//    )
//    user.missions = []
//    user.friends = []
//    return user
//}
