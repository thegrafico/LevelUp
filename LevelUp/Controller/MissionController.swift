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
        user.missions.append(mission)
        user.logEvent(.addMission, mission: mission)
        
        
        if mission.reminder.isEnabled {
            await notificationManager?.schedule(for: mission)
        } else {
            // just in case delete all notifications for this mission
            notificationManager?.cancel(for: mission)
        }
        
        do {
            try context.save()
            badgeManager?.increment(.filterMission(mission.type))
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
}
