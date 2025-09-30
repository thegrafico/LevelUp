//
//  ProgressLogExtension.swift
//  LevelUp
//
//  Created by Raúl Pichardo Avalo on 9/29/25.
//

import Foundation

extension ProgressLog {
    
    var isToday: Bool {
        Calendar.current.isDate(date, inSameDayAs: .now)
    }
}

extension ProgressLog {
    
}
