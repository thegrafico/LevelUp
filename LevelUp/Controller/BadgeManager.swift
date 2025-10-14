//
//  BadgeManager.swift
//  LevelUp
//
//  Created by Raúl Pichardo Avalo on 9/28/25.
//

import Foundation
import SwiftUI

@Observable
class BadgeManager {
    private var counts: [BadgeKey: Int] = [:]
    
    private var defaultCount: Int
    
    init (defaultCount: Int = 0) {
        self.defaultCount = defaultCount

    }

    func set(_ key: BadgeKey, to value: Int) {
        counts[key] = max(0, value)
    }

    func increment(_ key: BadgeKey, by value: Int = 1) {
        #if DEBUG
        print("[DEBUG] Incrementing badge for \(key) by \(value)")
        #endif
        counts[key, default: defaultCount] += value
    }

    func clear(_ key: BadgeKey) {
        counts[key] = 0
    }

    func count(for key: BadgeKey) -> Int {
        return counts[key, default: defaultCount]
    }
}

enum BadgeKey: Hashable {

    case LeaderboardNotification
    case HomeNotification
    case FriendsNotification
    case SettingsNotification
    
    case newCustomMission
    case newGlobalMission
    
    case AppNotification(AppNotification.Kind)
    case filterMission(MissionType)
}
