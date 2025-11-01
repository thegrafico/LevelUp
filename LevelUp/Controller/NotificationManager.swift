//
//  NotificationManager.swift
//  LevelUp
//
//  Created by Raúl Pichardo Avalo on 10/9/25.
//
//
//  NotificationManager.swift
//  LevelUp
//
//  Created by Raúl Pichardo Avalo on 10/28/25.
//

import Foundation
import UserNotifications

@MainActor
final class NotificationManager: ObservableObject {
    static let shared = NotificationManager()
    
    @Published private(set) var permissionGranted: Bool = false
    
     init() {
        // Check current permission on init
        Task {
            await refreshAuthorizationStatus()
        }
    }
    
    func updatePermissionGranded(_ newValue: Bool) {
        self.permissionGranted = newValue
    }
    
    // MARK: - Request Authorization
    func requestAuthorization() async {
        do {
            let granted = try await UNUserNotificationCenter.current()
                .requestAuthorization(options: [.alert, .sound, .badge])
            self.permissionGranted = granted
            print(granted ? "✅ Notification permission granted" : "❌ Permission denied")
        } catch {
            print("⚠️ Error requesting notification permission: \(error)")
        }
    }
    
    // MARK: - Refresh Current Status
    func refreshAuthorizationStatus() async {
        let settings = await UNUserNotificationCenter.current().notificationSettings()
        self.permissionGranted = (settings.authorizationStatus == .authorized ||
                                  settings.authorizationStatus == .provisional)
    }
    
    // MARK: - Schedule Reminder
    @MainActor
    func schedule(for mission: Mission) async {
        print("Scheduling notification")
        guard mission.reminder.isEnabled else {
            cancel(for: mission)
            return
        }
        guard permissionGranted else {
            print("⚠️ Notifications not permitted")
            return
        }

        cancel(for: mission)

        let reminder = mission.reminder
        let content = UNMutableNotificationContent()
        content.title = mission.title
        content.body = mission.details ?? "Don’t forget your mission today!"
        content.sound = .default

        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: reminder.time)
        let minute = calendar.component(.minute, from: reminder.time)

        // 👇 Default to all selected days, or just “today” if none
        let days = reminder.repeatDays.isEmpty ? nil : reminder.repeatDays
        let targetDays: [Weekday] = Array(days ?? [Weekday.today])

        for day in targetDays {
            var comps = DateComponents()
            comps.weekday = day.rawValue
            comps.hour = hour
            comps.minute = minute

            // Compute next occurrence of that day
            guard let nextDate = calendar.nextDate(
                after: Date(),
                matching: comps,
                matchingPolicy: .nextTime
            ) else { continue }

            // ⏱ Convert to date components for scheduling
            let triggerComps = calendar.dateComponents([.year, .month, .day, .hour, .minute, .weekday], from: nextDate)

            let trigger = UNCalendarNotificationTrigger(
                dateMatching: triggerComps,
                repeats: reminder.repeatsWeekly
            )

            let request = UNNotificationRequest(
                identifier: missionNotificationID(for: mission, day: day),
                content: content,
                trigger: trigger
            )

            do {
                try await UNUserNotificationCenter.current().add(request)
                let dateString = nextDate.formatted(date: .abbreviated, time: .shortened)
                print("📅 Scheduled \(reminder.repeatsWeekly ? "repeating" : "one-time") reminder for \(day.displayName) at \(dateString)")
            } catch {
                print("⚠️ Failed to schedule \(day.displayName): \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - Cancel Reminder(s)
    func cancel(for mission: Mission) {
        print("Canceling notification for mission: \(mission.title)")
        let identifiers: [String]
        if mission.reminder.repeatDays.isEmpty {
            identifiers = [missionNotificationID(for: mission)]
        } else {
            identifiers = mission.reminder.repeatDays.map { missionNotificationID(for: mission, day: $0) }
        }
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: identifiers)
    }
    
    func cancelAll() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
    
    // MARK: - ID helper
    private func missionNotificationID(for mission: Mission, day: Weekday? = nil) -> String {
        if let day = day {
            return "mission.\(mission.id.uuidString).day.\(day.rawValue)"
        } else {
            return "mission.\(mission.id.uuidString)"
        }
    }
}
