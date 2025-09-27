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
    var isSelected: Bool = false

    var reminderDate: Date?
    var createdAt: Date
    var id: UUID

    // store raw value instead of the enum directly
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
        completed: Bool = false,
        reminderDate: Date? = nil,
        id: UUID = UUID()
    ) {
        self.title = title
        self.icon = icon
        self.xp = xp
        self.id = id
        self.completed = completed
        self.reminderDate = reminderDate
        self.createdAt = Date()
        self.typeRaw = type.rawValue
    }
}

extension Mission {
    static let sampleData: [Mission] = [
        .init(title: "Run",           xp: 1, icon: "figure.run", ),
        .init(title: "Go to the Gym", xp: 1, icon: "dumbbell.fill"),
        .init(title: "Read",          xp: 1, icon: "book.fill"   ),
    ]
    
    static let sampleGlobalMissions: [Mission] = [
        // Health & Fitness
        .init(title: "Run 1 Mile", xp: 20, type: .global, icon: "figure.run", ),
        .init(title: "Go to the Gym", xp: 25, type: .global, icon: "dumbbell.fill"),
        .init(title: "Stretch for 10 Minutes", xp: 10, type: .global, icon: "figure.cooldown"),
        .init(title: "Drink 8 Glasses of Water", xp: 15, type: .global, icon: "drop.fill"),

        // Learning & Mind
        .init(title: "Read 20 Pages", xp: 15, type: .global, icon: "book.fill"),
        .init(title: "Meditate for 5 Minutes", xp: 10, type: .global, icon: "brain.head.profile"),
        .init(title: "Write in a Journal", xp: 12, type: .global, icon: "pencil.and.outline"),

        // Daily Life
        .init(title: "Clean Your Room", xp: 15, type: .global, icon: "trash.fill"),
        .init(title: "Cook a Healthy Meal", xp: 18, type: .global, icon: "fork.knife"),
        .init(title: "Walk the Dog", xp: 10, type: .global, icon: "pawprint.fill"),

        // Social
        .init(title: "Call a Friend", xp: 10, type: .global, icon: "phone.fill"),
        .init(title: "Help Someone Out", xp: 20, type: .global, icon: "hands.sparkles.fill"),

        // Productivity
        .init(title: "Finish a Task on Time", xp: 15, type: .global, icon: "checkmark.circle.fill"),
        .init(title: "Plan Tomorrow", xp: 12, type: .global, icon: "calendar"),
    ]
}

extension Mission {
    var isGlobal: Bool { type == .global }
    var isCustom: Bool { type == .custom }
}

enum MissionType: String, Codable, Identifiable, Equatable {
    case global, custom
    var id: String { rawValue }
}

enum MissionFilter: String, CaseIterable, Identifiable {
    case global = "Global"
    case custom = "Custom"
    case all = "All"
    var id: String { rawValue }
}

enum MissionSort: String, CaseIterable, Identifiable {
    case name = "Name"
    case xpAscending = "XP ↑"
    case xpDescending = "XP ↓"
    case creationDateAscending = "Creation Date ↑"
    case creationDateDescending = "Creation Date ↓"
    case completed = "Completed"
    
    var id: String { rawValue }
}

extension Mission {
    static let xpValues = [5, 10, 15, 20]
    
    static let availableIcons = [
        "figure.run", "dumbbell.fill", "book.fill", "brain.head.profile",
        "cup.and.saucer.fill", "drop.fill", "moon.fill", "sun.max.fill",
        "mappin.and.ellipse", "checkmark.circle.fill", "heart.fill", "star.fill"
    ]
}

extension Mission {
    
    var isReminderEnabled: Bool {
        return reminderDate != nil
    }
}

