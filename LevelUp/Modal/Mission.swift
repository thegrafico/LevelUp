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
    var completionDate: Date?  = nil
    var isSelected: Bool = false
    var reminderDate: Date?
    var typeRaw: String
    var type: MissionType {
        get { MissionType(rawValue: typeRaw) ?? .custom }
        set { typeRaw = newValue.rawValue }
    }
    
    // enconde it as json so swift data can handle it
    private var categoryData: Data?
    var category: MissionCategory {
        get {
            guard let data = categoryData else { return .general }
            return (try? JSONDecoder().decode(MissionCategory.self, from: data)) ?? .general
        }
        set {
            categoryData = try? JSONEncoder().encode(newValue)
        }
    }
    var details: String?
    var completionTimes: Int?
    
    var createdAt: Date
    var id: UUID

    init(
        title: String,
        xp: Int,
        type: MissionType = .custom,
        category: MissionCategory = .general,
        details: String? = nil,
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
        self.category = category
        self.details = details
        self.completionTimes = 0
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
    func printMission() {
        print("------")
        print("Mission: \(title)")
        print("XP: \(xp)")
        print("Type: \(type)")
        print("Category: \(category.name)")
        print("Completed: \(completed)")
        print("CompletedAt: \(String(describing: completionDate))")
        print("------")
    }
}
