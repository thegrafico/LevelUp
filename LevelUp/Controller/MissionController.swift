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
    
    init(context: ModelContext, badgeManager: BadgeManager? = nil) {
        self.context = context
        self.badgeManager = badgeManager
    }
    
    func insertMission(_ mission: Mission) {
        context.insert(mission)
        
        do {
            try context.save()
            if let badgeManager = badgeManager {
                badgeManager.increment(.filter(mission.type))
            }
        } catch {
            print("❌ Failed to insert mission: \(error)")
        }
    }
    
    func deleteMissions(_ missions: [Mission]) {
        for mission in missions {
            print("Deleting mission: \(mission.title)")
            context.delete(mission)
        }
        
        do {
            try context.save()
        } catch {
            print("❌ Failed to delete missions: \(error)")
        }
    }
}
