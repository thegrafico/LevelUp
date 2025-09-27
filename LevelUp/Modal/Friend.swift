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
    var username: String
    var avatar: String
    var xp: Int
    
    var user: User?   // inverse relationship
    
    init(
        username: String,
        avatar: String = "person.fill",
        xp: Int = 0,
        id: UUID = UUID()
    ) {
        self.username = username
        self.avatar = avatar
        self.xp = xp
        self.id = id
    }
}
