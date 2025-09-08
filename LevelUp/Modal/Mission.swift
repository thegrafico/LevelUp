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
    var id: UUID
    init(title: String, icon: String, xp: Int, completed: Bool = false, id: UUID = UUID()) {
        self.id = id
        self.title = title
        self.icon = icon
        self.xp = xp
        self.completed = completed
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
