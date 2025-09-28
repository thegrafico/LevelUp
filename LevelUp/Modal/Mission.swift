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
    var completionDate: Date?  // ✅ when it was completed
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
        completed: Bool = false,
        completionDate: Date? = nil,
        reminderDate: Date? = nil,
        id: UUID = UUID()
    ) {
        self.title = title
        self.icon = icon
        self.xp = xp
        self.id = id
        self.completed = completed
        self.completionDate = completionDate
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
    
    static let xpValues = [5, 10, 15, 20]
    
    static let availableIcons = [
        "figure.run", "dumbbell.fill", "book.fill", "brain.head.profile",
        "cup.and.saucer.fill", "drop.fill", "moon.fill", "sun.max.fill",
        "mappin.and.ellipse", "checkmark.circle.fill", "heart.fill", "star.fill"
    ]
    
}

extension Mission {
    var isGlobal: Bool { type == .global }
    var isCustom: Bool { type == .custom }
    var isReminderEnabled: Bool {
        return reminderDate != nil
    }
    
    var isNew: Bool {
        // check if this mission creation data was less than 2 amount of hours
        return Calendar.current.dateComponents([.hour], from: createdAt, to: Date()).hour! < 2
    }

}

enum MissionType: String, Codable, Identifiable, CaseIterable {
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

// MARK: FOR COMPLETION AND TODAYS UPDATES
extension Mission {
    /// True if mission was completed today
    var completedToday: Bool {
        guard let completionDate else { return false }
        return Calendar.current.isDateInToday(completionDate)
    }

    /// True if mission should be disabled (completed today)
    var isDisabledToday: Bool {
        completed && completedToday
    }

    /// Call when marking as completed
    func markCompleted() {
        completed = true
        isSelected = false
        completionDate = .now
    }
    
    func markIncomplete() {
        completed = false
        isSelected = false
        completionDate = nil
    }

    /// Auto reset if the day changed
    func refreshDailyState() {
        if !isDisabledToday {
            markIncomplete()
        }
    }
}

extension Mission {
    /// Returns true if completed within the given time interval (in seconds)
    func completedTime(inLast seconds: TimeInterval) -> Bool {
        guard let completionDate else { return false }
        return Date().timeIntervalSince(completionDate) <= seconds
    }

    /// Completed within the last X minutes
    func completedInLast(minutes: Int) -> Bool {
        return completedTime(inLast: Double(minutes) * 60)
    }

    /// Completed within the last X hours
    func completedInLast(hours: Int) -> Bool {
        return completedTime(inLast: Double(hours) * 3600)
    }
}

