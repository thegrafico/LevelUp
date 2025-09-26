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
    var type: MissionType
    var icon: String
    var completed: Bool
    var reminderDate: Date?
    var createdAt: Date
    private var completedDate: Date?
    private var isEnabled: Bool // NOT BEIGN USED FOR NOW.
    
    @Attribute(.unique) var id: UUID
    
    var user: User?   // inverse relationship
    
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
        self.type = type
        
        self.completed = completed
        self.reminderDate = reminderDate
        self.id = id
        
        self.completedDate = completed ? Date() : nil
        self.createdAt = Date()
        self.isEnabled = true
    }
    
    
    
    static let sampleData: [Mission] = []
//    static let sampleData: [Mission] = [
//        .init(title: "Run",           xp: 20, icon: "figure.run"  ),
//        .init(title: "Go to the Gym", xp: 15, icon: "dumbbell.fill"),
//        .init(title: "Read",          xp: 10, icon: "book.fill"   ),
//    ]
    
    static let sampleGlobalMissions: [Mission] = [
        // Health & Fitness
        .init(title: "Run 1 Mile", xp: 20, icon: "figure.run"),
        .init(title: "Go to the Gym", xp: 25, icon: "dumbbell.fill"),
        .init(title: "Stretch for 10 Minutes", xp: 10, icon: "figure.cooldown"),
        .init(title: "Drink 8 Glasses of Water", xp: 15, icon: "drop.fill"),

        // Learning & Mind
        .init(title: "Read 20 Pages", xp: 15, icon: "book.fill"),
        .init(title: "Meditate for 5 Minutes", xp: 10, icon: "brain.head.profile"),
        .init(title: "Write in a Journal", xp: 12, icon: "pencil.and.outline"),

        // Daily Life
        .init(title: "Clean Your Room", xp: 15, icon: "trash.fill"),
        .init(title: "Cook a Healthy Meal", xp: 18, icon: "fork.knife"),
        .init(title: "Walk the Dog", xp: 10, icon: "pawprint.fill"),

        // Social
        .init(title: "Call a Friend", xp: 10, icon: "phone.fill"),
        .init(title: "Help Someone Out", xp: 20, icon: "hands.sparkles.fill"),

        // Productivity
        .init(title: "Finish a Task on Time", xp: 15, icon: "checkmark.circle.fill"),
        .init(title: "Plan Tomorrow", xp: 12, icon: "calendar"),
    ]
}

enum MissionType: String, Codable {
    case global, custom
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

