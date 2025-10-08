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
    
    init(context: ModelContext, user: User? = nil, badgeManager: BadgeManager? = nil) {
        self.context = context
        self.user = user
        self.badgeManager = badgeManager
    }
    
    func insertMission(_ mission: Mission) {
        guard let user else { return }
        
        // Attach to user
        user.missions.append(mission)
        user.logEvent(.addMission, mission: mission)
        
        do {
            try context.save()
            badgeManager?.increment(.filter(mission.type))
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
                badgeManager?.increment(.filter(mission.type), by: -1)
            }
            
            user.logEvent(.deleteMission, mission: mission)
            user.missions.removeAll { $0.id == mission.id }
            context.delete(mission) // not strictly needed since removing from user + cascade should handle it
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
            user.addXP(mission.xp)
            user.logEvent(.completedMission, mission: mission)
        }

        do {
            try context.save()
            user.updateStreakIfNeeded()  // ✅ move here, after the save
            try context.save()           // save again if streak updated
        } catch {
            print("❌ Failed to mark mission as complete: \(error)")
        }
    }
    
    func printMissions(_ missions: [Mission]) {
        for mission in missions {
            print("Mission: \(mission.title), type: \(mission.type), completed today?: \(mission.completedToday)")
        }
    }
}
