//
//  MissionController.swift
//  LevelUp
//
//  Created by Raúl Pichardo Avalo on 9/27/25.
//
import Foundation
import SwiftData


@MainActor
final class MissionController: ObservableObject {
    private let context: ModelContext
    private let badgeManager: BadgeManager?
    private let user: User?
    private let notificationManager: NotificationManager?
    
    init(context: ModelContext, user: User? = nil, badgeManager: BadgeManager? = nil, notificationManager: NotificationManager? = nil) {
        self.context = context
        self.user = user
        self.badgeManager = badgeManager
        self.notificationManager = notificationManager
    }
    
    func insertMission(_ mission: Mission) async {
        guard let user else { return }
        
        // Attach to user
        user.addMission(mission)
        user.logEvent(.addMission, mission: mission)
        
        
        if mission.reminder.isEnabled {
            await notificationManager?.schedule(for: mission)
        } else {
            // just in case delete all notifications for this mission
            notificationManager?.cancel(for: mission)
        }
        
        do {
            try context.save()
            badgeManager?.increment(mission.filterBadgeKey)
            badgeManager?.increment(mission.categoryBadgeKey)
        } catch {
            print("❌ Failed to insert mission: \(error)")
        }
    }
    
    func updateCompleteStatus(for missions: [Mission]) {
        for mission in missions {
            mission.refreshDailyState()
        }
    }
    
    func deleteMissions(_ missions: [Mission]) {
        guard let user else { return }
        
        for mission in missions {
            print("Deleting mission: \(mission.title)")
            
            if mission.isNew {
                badgeManager?.increment(.filterMission(mission.type), by: -1)
            }
            
            user.logEvent(.deleteMission, mission: mission)
            
            notificationManager?.cancel(for: mission)
            
            user.missions.removeAll { $0.id == mission.id }
            context.delete(mission)
        }
        
        do {
            try context.save()
        } catch {
            print("❌ Failed to delete missions: \(error)")
        }
    }
    
    func markAsCompleted(_ missions: [Mission]) {
        guard let user else { return }

        for mission in missions {
            mission.markCompleted()
            user.stats.addXP(mission.xp)
            user.logEvent(.completedMission, mission: mission)
        }

        do {
            try context.save()
            
            user.updateStreakIfNeeded()
            try context.save()
        } catch {
            print("❌ Failed to mark mission as complete: \(error)")
        }
    }
    
    func printMissions(_ missions: [Mission]) {
        for mission in missions {
            print("Mission: \(mission.title), type: \(mission.type), completed today?: \(mission.completedToday)")
        }
    }
    
    
    func sendMission(_ mission: Mission, to friend: Friend) async throws {
        
        guard let sender = user else {
            print("User not found...")
            throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "User information not found"])
        }
        
        guard sender.hasFriend(withId: friend.friendId) else {
            print("Not your friend")
            throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Is not your friend."])
        }
        
        try await Task.sleep(nanoseconds: 400_000_000)
        
        // TODO: remove on production. just for testing purpouse
        
        let friendId = friend.friendId
        let senderId = sender.id
        let pendingStatus = AppNotification.StatusNotification.pending.rawValue
        
        let queryToGetMissionRequestBySender = FetchDescriptor<MissionRequest>(
            predicate: #Predicate {
                $0.from.friendId == senderId
                && $0.to.friendId == friendId
                && $0.statusRaw == pendingStatus
             }
        )
        
        let existingMissionRequest = try context.fetch(queryToGetMissionRequestBySender)
        
        if let active = existingMissionRequest.first(where: { $0.mission.id == mission.id }) {
            print("❌ A Mission pending request already exists: \(active.id)")
            throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Mission already sent."])
        }

        
        if let reusable = existingMissionRequest.first(where: { missionRequest in
            missionRequest.status == .canceled
            || missionRequest.status == .declined
        }) {
            print("Reusing mission request")
            reusable.updateStatus(to: .pending)
            reusable.updateMission(with: mission)
            try context.save()
            return
        }
        
        print("Creating a new Mission Request...")
        let request = MissionRequest(
            from: sender.asFriend(),
            to: friend,
            mission: mission,
            status: .pending
        )
        do {
            context.insert(request)
            try context.save()
            print("Mission Request sent sucessfully!: From: \(request.from.friendId) to: \(request.to.friendId)")
        } catch {
            print("There was an error: \(error)")
            throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "There was a problem sharing this mission."])
        }
        
    }
}
