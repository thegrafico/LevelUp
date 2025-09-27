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
    
    init(context: ModelContext) {
        self.context = context
    }
    
    func deleteMissions(_ missions: [Mission]) {
        for mission in missions {
            context.delete(mission)
        }
        
        do {
            try context.save()
        } catch {
            print("❌ Failed to delete missions: \(error)")
        }
    }
}
