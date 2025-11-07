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
    var details: String?
    var completionTimes: Int?
    
    // MARK: For querying by type
    var typeRaw: String
    var type: MissionType {
        get { MissionType(rawValue: typeRaw) ?? .custom }
        set { typeRaw = newValue.rawValue }
    }
    
    // MARK: Enconde it as JSON so swift Data can store structs and be able to query
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
    
    // MARK: Reminders for the mission
    private var reminderData: Data? = nil
    var reminder: Reminder {
        get {
            if let data = reminderData,
               let decoded = try? JSONDecoder().decode(Reminder.self, from: data) {
                return decoded
            }
            return Reminder() // 👈 default state (disabled)
        }
        set {
            reminderData = try? JSONEncoder().encode(newValue)
        }
    }
    
    var createdAt: Date
    var id: UUID
    
    init(
        title: String,
        xp: Int,
        type: MissionType = .custom,
        category: MissionCategory = .general,
        details: String? = nil,
        icon: String,
        reminder: Reminder = Reminder(),
        completed: Bool = false,
        id: UUID = UUID()
    ) {
        self.title = title
        self.icon = icon
        self.xp = xp
        self.id = id
        self.completed = completed
        self.createdAt = Date()
        self.typeRaw = type.rawValue
        self.category = category
        self.details = details
        self.completionTimes = 0
        self.reminder = reminder
    }
}

extension Mission {
    
    func asCopy() -> Mission {
        let copy = Mission(
            title: self.title,
            xp: self.xp,
            type: self.type,
            category: self.category,
            details: self.details,
            icon: self.icon,
        )
        
        return copy
    }

    /// Updates the reminder state based on current date/time.
     func refreshReminderStatus() {
         guard reminder.isEnabled else {
             print("Reminder is not enabled for \(title)")
             return
         }

        // Only auto-disable one-time reminders
        if isReminderExpired {
            reminder.isEnabled = false
            print("🕓 Reminder expired — disabling \(title)")
        }
    }

    /// Returns true if this mission's reminder is currently expired
    var isReminderExpired: Bool {
        !reminder.repeatsWeekly && reminder.time < Date()
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

enum Weekday: Int, CaseIterable, Codable, Identifiable, Hashable {
    case sunday = 1, monday, tuesday, wednesday, thursday, friday, saturday
    var id: Int { rawValue }
    
    var displayName: String {
        switch self {
        case .sunday: return "Sun"
        case .monday: return "Mon"
        case .tuesday: return "Tue"
        case .wednesday: return "Wed"
        case .thursday: return "Thu"
        case .friday: return "Fri"
        case .saturday: return "Sat"
        }
    }
    
    var shortName: String {
        switch self {
        case .monday: return "M"
        case .tuesday: return "T"
        case .wednesday: return "W"
        case .thursday: return "T"
        case .friday: return "F"
        case .saturday: return "S"
        case .sunday: return "S"
        }
    }
    
    var isWeekend: Bool { self == .saturday || self == .sunday }
    
    static var weekdays: [Weekday] { [.monday, .tuesday, .wednesday, .thursday, .friday] }
    static var weekend: [Weekday] { [.saturday, .sunday] }
    
    static var today: Weekday {
        let calendar = Calendar.current
        let weekdayNumber = calendar.component(.weekday, from: Date())
        return Weekday(rawValue: weekdayNumber)!
    }
}


struct Reminder: Codable, Hashable {
    var isEnabled: Bool = false
    var time: Date = Date.currentHour
    var repeatDays: Set<Weekday> = []
    var repeatsWeekly: Bool = true // by default repeat weekly
    var id: String = UUID().uuidString
    
    // MARK: - Computed Helpers
    var isRepeating: Bool { !repeatDays.isEmpty }
    var isWeekdaysOnly: Bool { repeatDays == Set(Weekday.weekdays) }
    var isWeekendOnly: Bool { repeatDays == Set(Weekday.weekend) }
    
    func repeats(on day: Weekday) -> Bool { repeatDays.contains(day) }
    
    mutating func toggle(day: Weekday) {
        if repeatDays.contains(day) { repeatDays.remove(day) } else { repeatDays.insert(day) }
    }
    
    mutating func disable() {
        isEnabled = false
        repeatDays.removeAll()
    }
    
    var descriptionText: String {
        guard isEnabled else { return "No reminder set" }
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        let timeString = formatter.string(from: time)
        if repeatDays.isEmpty { return "Once at \(timeString)" }
        if repeatDays.count == 7 { return "Every day at \(timeString)" }
        if isWeekendOnly { return "Weekends at \(timeString)" }
        if isWeekdaysOnly { return "Weekdays at \(timeString)" }
        let days = repeatDays.sorted(by: { $0.rawValue < $1.rawValue }).map(\.displayName).joined(separator: ", ")
        return "\(days) at \(timeString)"
    }
    //
    //    func nextTriggerDate(from now: Date = .now) -> Date? { /* as above */ }
    //
    //    func notificationIDs(for missionID: UUID) -> [String] { /* as above */ }
}

extension Date {
    static var currentHour: Date {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day, .hour], from: Date())
        return calendar.date(from: components)!
    }
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
