//
//  FriendExtensions.swift
//  LevelUp
//
//  Created by Raúl Pichardo Avalo on 9/29/25.
//

import Foundation


// MARK: - Sample Friends
extension Friend {
    static let sampleFriends: [Friend] = [
        .init(username: "Raúl", stats: .init(level: 20, bestStreakCount: 20, topMission: "Swimming"), friendId: UUID()),
        .init(username: "Raúl", stats: .init(level: 30, bestStreakCount: 10, topMission: "Running"), friendId: UUID()),
    ]
}
