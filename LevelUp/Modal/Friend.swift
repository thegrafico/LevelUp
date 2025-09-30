//
//  Friends.swift
//  LevelUp
//
//  Created by Raúl Pichardo Avalo on 9/10/25.
//

import Foundation
import SwiftData

@Model
final class Friend: Identifiable {
    var id: UUID
    var userId: UUID
    var username: String
    var avatar: String
    var xp: Int
        
    init(
        userId: UUID,
        username: String,
        avatar: String = "person.fill",
        xp: Int = 0,
        id: UUID = UUID()
    ) {
        self.userId = userId
        self.username = username
        self.avatar = avatar
        self.xp = xp
        self.id = id
    }
}
