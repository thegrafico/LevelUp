//
//  ProgressLog.swift
//  LevelUp
//
//  Created by Raúl Pichardo Avalo on 9/10/25.
//

import Foundation
import SwiftData


@Model
final class ProgressLog: Identifiable {
    var id: UUID
    /// Use the start-of-day timestamp to represent the “date key” for a log
    var date: Date

    @Relationship(deleteRule: .cascade)
    var events: [ProgressEvent] = []

    init(date: Date = Date(), events: [ProgressEvent] = []) {
        self.id = UUID()
        // Normalize to start of day
        self.date = Calendar.current.startOfDay(for: date)
        
        self.events = events
    }
}

@Model
final class ProgressEvent: Identifiable {
    var id: UUID
    var date: Date
    var typeRaw: String
    var missionId: UUID?
    var missionTitle: String?
    var missionXP: Int?
    var missionType: String?
    var missionCompletionTime: Date?
    var userLevel: Int?
    var details: String?
    var userXP: Double?

    var type: ProgressEventType {
        get { ProgressEventType(rawValue: typeRaw) ?? .addMission }
        set { typeRaw = newValue.rawValue }
    }

    init(
        type: ProgressEventType,
        missionId: UUID? = nil,
        missionTitle: String? = nil,
        missionXP: Int? = nil,
        missionType: MissionType? = nil,
        missionCompletionTime: Date? = nil,
        userLevel: Int? = nil,
        details: String? = nil,
        userXp: Double? = nil,
        date: Date = Date()
    ) {
        self.id = UUID()
        self.date = date
        self.typeRaw = type.rawValue
        self.missionId = missionId
        self.missionTitle = missionTitle
        self.missionXP = missionXP
        self.missionType = missionType?.rawValue
        self.missionCompletionTime = missionCompletionTime
        self.userLevel = userLevel
        self.details = details
        self.userXP = userXp
        
    }
}

// The event type enum
enum ProgressEventType: String, Codable {
    case addMission
    case deleteMission
    case editedMission
    case completedMission
    case userLevelUp
    case friendAdded
}
