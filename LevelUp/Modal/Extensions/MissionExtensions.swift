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
        // Default custom missions (each with custom categories)
        .init(
            title: "Run",
            xp: 10,
            type: .custom,
            category: .custom(.init(name: "Fitness", colorHex: "#FF6B6B")),
            icon: "figure.run",
            completed: false,
            
        ),
        .init(
            title: "Go to the Gym",
            xp: 12,
            type: .custom,
            category: .custom(.init(name: "Fitness", colorHex: "#FF6B6B")),
            icon: "dumbbell.fill",
            completed: false,
            
        ),
        .init(
            title: "Read a Book",
            xp: 8,
            type: .custom,
            category: .custom(.init(name: "Focus", colorHex: "#4ECDC4")),
            icon: "book.fill",
            completed: false,
            
        ),
        .init(
            title: "Meditate 10 min",
            xp: 10,
            type: .custom,
            category: .custom(.init(name: "Mindfulness", colorHex: "#FFD93D")),
            icon: "brain.head.profile",
            completed: false,
            
        ),
    ]
    
    
    static let sampleGlobalMissions: [Mission] = [
        // 🌿 Health & Fitness
        .init(
            title: "Run 1 Mile",
            xp: 20,
            type: .global,
            category: .custom(.init(name: "Fitness", colorHex: "#FF6B6B")),
            icon: "figure.run",
            completed: false,
        ),
        .init(
            title: "Go to the Gym",
            xp: 25,
            type: .global,
            category: .custom(.init(name: "Fitness", colorHex: "#FF6B6B")),
            icon: "dumbbell.fill",
            completed: false,
            
        ),
        .init(
            title: "Stretch for 10 Minutes",
            xp: 10,
            type: .global,
            category: .custom(.init(name: "Fitness", colorHex: "#FF6B6B")),
            icon: "figure.cooldown",
            completed: false,
            
        ),
        .init(
            title: "Drink 8 Glasses of Water",
            xp: 15,
            type: .global,
            category: .custom(.init(name: "Health", colorHex: "#1DD1A1")),
            icon: "drop.fill",
            completed: false,
            
        ),

        // 📖 Learning & Mind
        .init(
            title: "Read 20 Pages",
            xp: 15,
            type: .global,
            category: .custom(.init(name: "Focus", colorHex: "#4ECDC4")),
            icon: "book.fill",
            completed: false,
            
        ),
        .init(
            title: "Meditate for 5 Minutes",
            xp: 10,
            type: .global,
            category: .custom(.init(name: "Mindfulness", colorHex: "#FFD93D")),
            icon: "brain.head.profile",
            completed: false,
            
        ),
        .init(
            title: "Write in a Journal",
            xp: 12,
            type: .global,
            category: .custom(.init(name: "Mindfulness", colorHex: "#FFD93D")),
            icon: "pencil.and.outline",
            completed: false,
            
        ),

        // 🧹 Daily Life
        .init(
            title: "Clean Your Room",
            xp: 15,
            type: .global,
            category: .custom(.init(name: "Lifestyle", colorHex: "#FF9F43")),
            icon: "trash.fill",
            completed: false,
            
        ),
        .init(
            title: "Cook a Healthy Meal",
            xp: 18,
            type: .global,
            category: .custom(.init(name: "Lifestyle", colorHex: "#FF9F43")),
            icon: "fork.knife",
            completed: false,
            
        ),
        .init(
            title: "Walk the Dog",
            xp: 10,
            type: .global,
            category: .custom(.init(name: "Lifestyle", colorHex: "#FF9F43")),
            icon: "pawprint.fill",
            completed: false,
            
        ),

        // 🫂 Social
        .init(
            title: "Call a Friend",
            xp: 10,
            type: .global,
            category: .custom(.init(name: "Social", colorHex: "#54A0FF")),
            icon: "phone.fill",
            completed: false,
            
        ),
        .init(
            title: "Help Someone Out",
            xp: 20,
            type: .global,
            category: .custom(.init(name: "Social", colorHex: "#54A0FF")),
            icon: "hands.sparkles.fill",
            completed: false,
            
        ),

        // ✅ Productivity
        .init(
            title: "Finish a Task on Time",
            xp: 15,
            type: .global,
            category: .custom(.init(name: "Productivity", colorHex: "#5F27CD")),
            icon: "checkmark.circle.fill",
            completed: false,
            
        ),
        .init(
            title: "Plan Tomorrow",
            xp: 12,
            type: .global,
            category: .custom(.init(name: "Thegrafico", colorHex: "#10AC84")),
            icon: "calendar",
            completed: false,
            
        ),
    ]
}

extension Mission {
    
    static let SampleLocalMissions: [Mission] = [
        // Health & Fitness
        // Core Training (Saitama Routine)
        .init(title: "100 Push-Ups", xp: 25, type: .custom, icon: "figure.strengthtraining.traditional"),
        .init(title: "100 Sit-Ups", xp: 25, type: .custom, icon: "figure.core.training"),
        .init(title: "100 Squats", xp: 25, type: .custom, icon: "figure.strengthtraining.functional"),
        .init(title: "Run 10 Kilometers", xp: 40, type: .custom, icon: "figure.run"),
        .init(title: "Cold Shower Training", xp: 20, type: .custom, icon: "snowflake"),
        .init(title: "No A/C Challenge", xp: 15, type: .custom, icon: "wind"),

        // Solo Leveling Daily Quests
        .init(title: "Grind a Skill", xp: 25, type: .custom, icon: "brain.head.profile"),
        .init(title: "Cook a Meal", xp: 18, type: .custom, icon: "fork.knife"),
        .init(title: "Read 10 Pages", xp: 15, type: .custom, icon: "book.fill"),
        .init(title: "Help Someone", xp: 20, type: .custom, icon: "hands.sparkles.fill"),
        .init(title: "Meditation for 10m", xp: 100, type: .custom, icon: "sparkles"),
    ]
    
    static let xpValues = [5, 10, 15, 20]
    
    static let availableIcons = [
        "figure.run", "dumbbell.fill", "book.fill", "brain.head.profile",
        "cup.and.saucer.fill", "drop.fill", "moon.fill", "sun.max.fill",
        "mappin.and.ellipse", "checkmark.circle.fill", "heart.fill", "star.fill"
    ]
    
}
