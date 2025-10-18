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
            AppNotification.self,
            Friend.self,
            FriendRequest.self,
            Mission.self,
            ProgressLog.self,
            User.self,
            UserSettings.self,
            UserStats.self
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
        print("📦 Inserting sample users with missions, progress, and friend requests...")
        
        let missions = Mission.sampleData
        let stats = UserStats(level: 3, xp: 240)
        
        // 👤 Create 2 demo users
        
        let user1 = User(
            username: "RaúlTest",
            passwordHash: "hash123",
            email: "raul@test.com",
            stats: stats,
            id: UUID(uuidString: "11111111-1111-1111-1111-111111111111")!
        )
        
        let user2 = User(
            username: "SwiftMaster",
            passwordHash: "hash2",
            email: "swift@demo.com",
            stats: UserStats(level: 2, xp: 120)
        )
        
        let user3 = User(
            username: "test3",
            passwordHash: "hash2",
            email: "swift2@demo.com",
            stats: UserStats(level: 50, xp: 120)
        )
        
        let user4 = User(
            username: "test4",
            passwordHash: "hash2",
            email: "swift2@demo.com",
            stats: UserStats(level: 50, xp: 120)
        )
        
        // ✅ Assign some missions
        user1.missions = Array(missions.prefix(3))
        user2.missions = Array(missions.suffix(3))
        
        // ✅ Connect them as friends
        let friend1 = user1.asFriend()
        let friend2 = user2.asFriend()
        let friend3 = user3.asFriend()
        let friend4 = user4.asFriend()
        
        user1.friends = [friend2]
        user2.friends = [friend1]
        
        // ✅ Insert users into context first
        context.insert(user1)
        context.insert(user2)
        context.insert(user3)
        context.insert(user4)
        
        // ✅ Add a pending friend request (example)
        let pendingRequest = FriendRequest(
            from: friend1,
            to: friend3,
            status: .pending
        )
        
        // ✅ Add an accepted request (example)
        let acceptedRequest = FriendRequest(
            from: friend1,
            to: friend4,
            status: .pending
        )
        
        // ✅ Insert into context
        context.insert(pendingRequest)
        context.insert(acceptedRequest)
        
        // ✅ Insert sample notifications for testing
        let notif1 = AppNotification(
            kind: .friendRequest,
            sender: friend3,
            receiverId: user1.id,
            message: "sent you a friend request!",
            isRead: false
        )

        let notif2 = AppNotification(
            kind: .challenge,
            sender: friend4,
            receiverId: user1.id,
            message: "challenged you to a 5K run!",
            isRead: false
        )

        // 👇 Insert them before saving so they exist when the query runs
        context.insert(notif1)
        context.insert(notif2)

        print("✅ Inserted sample AppNotifications: \(notif1.title), \(notif2.title)")
        
        print("""
        ✅ Inserted users:
            - \(user1.username): id: \(user1.id)
            - \(user2.username): id: \(user2.id)
            - \(user3.username): id: \(user3.id)
            - \(user4.username): id: \(user4.id)
        ✅ Inserted friend requests:
            - Pending: from \(friend3.username) → \(user1.username)
            - Pending: from \(friend4.username) → \(user1.username)
        """)
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

extension SampleData {
    static var sampleFriend1: Friend = Friend(username: "thegraficoTest", stats: UserStats(level: 10, xp: 20, bestStreakCount: 2))
    static var sampleFriend2: Friend = Friend(username: "masterTest", stats: UserStats(level: 15, xp: 100, bestStreakCount: 20))
    static var sampleFriend3: Friend = Friend(username: "masterTestadsd", stats: UserStats(level: 15, xp: 100, bestStreakCount: 20))
    
    static var sampleFriendRequest1: FriendRequest = .init(from: sampleFriend1, to: sampleFriend2, status: .pending)
    static var sampleFriendRequest2: FriendRequest = .init(from: sampleFriend3, to: sampleFriend1, status: .pending)
    
    static var sampleAppNotifications: [AppNotification] = [
        .init(
            kind: .friendRequest,
            sender: .init(username: "Thegrafico",
                          stats: UserStats(level: 10)
                         ),
            message: "sent you a friend request.",
            isRead: false
        ),

        .init(
            kind: .challenge,
            sender: .init(username: "Thegrafico",
                            stats: UserStats(level: 10,
                                               topMission: "10K",
                                               challengeWonCount: 5,
                                              ),
                         ),
            message: "challenged you to a 5K run!"
        ),

        .init(kind: .friendRequest, message: "wants to connect with you.")
    ]
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
