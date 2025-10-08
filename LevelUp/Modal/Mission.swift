//
//  Mission.swift
//  LevelUp
//
//  Created by Raúl Pichardo Avalo on 9/6/25.
//

import Foundation
import SwiftUI
import SwiftData


@Model
final class Mission: Identifiable {
    var title: String
    var xp: Int
    var icon: String
    
    var completed: Bool
    var completionDate: Date?  = nil // ✅ when it was completed
    var isSelected: Bool = false

    var reminderDate: Date?
    
    // MARK: track when task was created
    var createdAt: Date
    var id: UUID

    // MARK: For filtering mostly
    var typeRaw: String
    var type: MissionType {
        get { MissionType(rawValue: typeRaw) ?? .custom }
        set { typeRaw = newValue.rawValue }
    }

    init(
        title: String,
        xp: Int,
        type: MissionType = .custom,
        icon: String,
        reminderDate: Date? = nil,
        completed: Bool = false,
        id: UUID = UUID()
    ) {
        self.title = title
        self.icon = icon
        self.xp = xp
        self.id = id
        self.reminderDate = reminderDate
        self.completed = completed
        self.createdAt = Date()
        self.typeRaw = type.rawValue
    }
}

enum MissionType: String, Codable, Identifiable, CaseIterable {
    case custom = "Custom"
    case global = "Global"
    case all = "All"
    var id: String { rawValue }
}

enum MissionSort: String, CaseIterable, Identifiable {
    case name = "Name"
    case xpAscending = "XP ↑"
    case xpDescending = "XP ↓"
    case creationDateAscending = "Creation Date ↑"
    case creationDateDescending = "Creation Date ↓"
    
    var id: String { rawValue }
}

extension Mission {
    
    func printMission()  {
        print("------")
        print("Mission: \(title)")
        print("XP: \(xp)")
        print("Type: \(type)")
        print("Completed: \(completed)")
        print("CompletedAt: \(String(describing: completionDate))")
        print("------")
    }
}

