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
    var icon: String
    var xp: Int
    var completed: Bool
    var reminderDate: Date?
    var type: MissionType
    
    private var completedDate: Date?
    private var createdAt: Date
    
    @Attribute(.unique) var id: UUID
    
    var user: User?   // inverse relationship
    
    init(
        title: String,
        icon: String,
        xp: Int,
        type: MissionType = .custom,
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
    }
    
    static let sampleData: [Mission] = [
        .init(title: "Run",          icon: "figure.run",     xp: 20),
        .init(title: "Go to the Gym",icon: "dumbbell.fill",  xp: 15),
        .init(title: "Read",         icon: "book.fill",      xp: 10),
        .init(title: "Run",          icon: "figure.run",     xp: 20),
        .init(title: "Go to the Gym",icon: "dumbbell.fill",  xp: 15),
        .init(title: "Read",         icon: "book.fill",      xp: 10),
        .init(title: "Run",          icon: "figure.run",     xp: 20),
        .init(title: "Go to the Gym",icon: "dumbbell.fill",  xp: 15),
        .init(title: "Read",         icon: "book.fill",      xp: 10)
    ]
}

enum MissionType: String, Codable {
    case global, custom
}
