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
    var xpGained: Int
    
    var missionTitle: String?
    var missionID: UUID?
    
    var id: UUID
    
    init(userId: UUID, date: Date = .now, xpGained: Int, missionTitle: String? = nil, id: UUID = UUID()) {
        self.userId = userId
        self.date = date
        self.xpGained = xpGained
        self.missionTitle = missionTitle
        self.id = id
    }
}

extension Array where Element == ProgressLog {
    
    func xpByMonth() -> [(month: String, totalXP: Int)] {
        let grouped = Dictionary(grouping: self) { log in
            let comps = Calendar.current.dateComponents([.year, .month], from: log.date)
            return comps
        }
        return grouped.map { (comp, logs) in
            let total = logs.reduce(0) { $0 + $1.xpGained }
            let monthName = DateFormatter().monthSymbols[(comp.month ?? 1) - 1]
            return ("\(monthName) \(comp.year ?? 0)", total)
        }
        .sorted { $0.month < $1.month }
    }
    
}
