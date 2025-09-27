//
//  ProgressLog.swift
//  LevelUp
//
//  Created by Raúl Pichardo Avalo on 9/10/25.
//

import Foundation
import SwiftData

@Model
final class ProgressLog: Identifiable {
    var userId: UUID
    var date: Date
    
    // MARK: LIST OF MISSION FROM THE USER
    var missions: [Mission]
    
    var id: UUID
    
    init(userId: UUID, date: Date = .now, missions: [Mission] = [], id: UUID = UUID()) {
        self.userId = userId
        self.date = date
        self.missions = missions
        self.id = id
    }
}


extension ProgressLog {
    
    var isToday: Bool {
        Calendar.current.isDate(date, inSameDayAs: .now)
    }
}
