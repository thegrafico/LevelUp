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
            Friend.self,
            Mission.self,
            ProgressLog.self,
            User.self,
            UserSettings.self
        ])
        
        let modelConfiguration = ModelConfiguration(schema:schema, isStoredInMemoryOnly: true)
        
        do {
            modelContainer = try ModelContainer(for: schema, configurations: [modelConfiguration])
            
            insertSampleData()
            
            try context.save()
        } catch {
            fatalError("Unable to create Model Container: \(error)")
        }
        
    }
    
    private func insertSampleData() {
        for mission in Mission.sampleData {
            context.insert(mission)
        }
    }
    
}
