//
//  MissionExtensions.swift
//  LevelUp
//
//  Created by Raúl Pichardo Avalo on 9/29/25.
//

import Foundation

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
    /// Check if the mission was completed within the last given time interval.
    func completedInLast(_ component: Calendar.Component, _ value: Int) -> Bool {
        guard let completionDate else { return false }
        let now = Date()
        guard let threshold = Calendar.current.date(byAdding: component, value: -value, to: now) else {
            return false
        }
        return completionDate >= threshold && completionDate <= now
    }
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

extension Mission {
    static let sampleData: [Mission] = [
        .init(title: "Run",           xp: 1, icon: "figure.run", ),
        .init(title: "Go to the Gym", xp: 1, icon: "dumbbell.fill"),
        .init(title: "Read",          xp: 1, icon: "book.fill"   ),
    ]
    
    static let sampleGlobalMissions: [Mission] = [
        // Health & Fitness
        .init(title: "Run 1 Mile", xp: 20, type: .global, icon: "figure.run", completed: false ),
        .init(title: "Go to the Gym", xp: 25, type: .global, icon: "dumbbell.fill", completed: false),
        .init(title: "Stretch for 10 Minutes", xp: 10, type: .global, icon: "figure.cooldown", completed: false),
        .init(title: "Drink 8 Glasses of Water", xp: 15, type: .global, icon: "drop.fill", completed: false),

        // Learning & Mind
        .init(title: "Read 20 Pages", xp: 15, type: .global, icon: "book.fill", completed: false),
        .init(title: "Meditate for 5 Minutes", xp: 10, type: .global, icon: "brain.head.profile", completed: false),
        .init(title: "Write in a Journal", xp: 12, type: .global, icon: "pencil.and.outline", completed: false),

        // Daily Life
        .init(title: "Clean Your Room", xp: 15, type: .global, icon: "trash.fill", completed: false),
        .init(title: "Cook a Healthy Meal", xp: 18, type: .global, icon: "fork.knife", completed: false),
        .init(title: "Walk the Dog", xp: 10, type: .global, icon: "pawprint.fill", completed: false),

        // Social
        .init(title: "Call a Friend", xp: 10, type: .global, icon: "phone.fill", completed: false),
        .init(title: "Help Someone Out", xp: 20, type: .global, icon: "hands.sparkles.fill", completed: false),

        // Productivity
        .init(title: "Finish a Task on Time", xp: 15, type: .global, icon: "checkmark.circle.fill", completed: false),
        .init(title: "Plan Tomorrow", xp: 12, type: .global, icon: "calendar", completed: false),
    ]
    
    static let xpValues = [5, 10, 15, 20]
    
    static let availableIcons = [
        "figure.run", "dumbbell.fill", "book.fill", "brain.head.profile",
        "cup.and.saucer.fill", "drop.fill", "moon.fill", "sun.max.fill",
        "mappin.and.ellipse", "checkmark.circle.fill", "heart.fill", "star.fill"
    ]
    
}
