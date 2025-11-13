//
//  UserAchievements.swift
//  LevelUp
//
//  Created by Raúl Pichardo Avalo on 11/11/25.
//

import Foundation
import SwiftData
import SwiftUI

@Model
final class Achievement: Identifiable {
    @Attribute(.unique) var id: UUID
    var title: String
    var icon: String
    var colorHex: String
    var unlockedAt: Date
    var details: String?
    var isRead: Bool
    
    init(title: String, icon: String, color: Color, details: String? = nil, isRead: Bool = false, id: UUID = UUID()) {
        self.id = id
        self.title = title
        self.icon = icon
        self.colorHex = color.toHex() // ← small Color extension below
        self.unlockedAt = Date()
        self.details = details
        self.isRead = isRead
    }
}
import SwiftUI


struct BadgeAchievement: Identifiable {
    let id: UUID
    let title: String
    let icon: String
    let color: Color
    let condition: (User) -> Bool // dynamic unlock check
}

extension Achievement {
    static let ALL_BADGE_ACHIEVEMENTS: [BadgeAchievement] = [
        // 🌱 Getting Started
        BadgeAchievement(
            id: UUID(uuidString: "E32B9F9F-5A44-4E32-B6EE-8CCDE9BEE001")!,
            title: "First Mission",
            icon: "star.fill",
            color: .yellow,
            condition: { user in
                user.stats.missionCompletedCount >= 1
            }
        ),
        BadgeAchievement(
            id: UUID(uuidString: "C91A1C14-9C1A-4A25-B9E4-6D2E7AE76E02")!,
            title: "Consistency",
            icon: "clock.fill",
            color: .blue,
            condition: { user in
                user.stats.bestStreakCount >= 365
            }
        ),
        BadgeAchievement(
            id: UUID(uuidString: "71D7E52C-0DA8-4C0A-A5A0-8EB9305A1E03")!,
            title: "First Streak",
            icon: "flame.fill",
            color: .orange,
            condition: { user in
                user.stats.bestStreakCount >= 1
            }
        ),
        BadgeAchievement(
            id: UUID(uuidString: "4A6436B9-82D1-474C-845E-FB9F0A657E04")!,
            title: "5-Day Streak",
            icon: "calendar.badge.clock",
            color: .pink,
            condition: { user in
                user.stats.bestStreakCount >= 5
            }
        ),
        BadgeAchievement(
            id: UUID(uuidString: "1AEF8A6F-3B45-4D22-88FA-4C9A5AD61E05")!,
            title: "10-Day Streak",
            icon: "calendar.badge.exclamationmark",
            color: .red,
            condition: { user in
                user.stats.bestStreakCount >= 10
            }
        ),

        // 💪 Progress & Effort
        BadgeAchievement(
            id: UUID(uuidString: "AC78A879-52A9-4FBA-B6B1-8D2D2E53E006")!,
            title: "50 XP Earned",
            icon: "bolt.fill",
            color: .teal,
            condition: { user in
                user.xpGainedTotal >= 50
            }
        ),
        BadgeAchievement(
            id: UUID(uuidString: "5CC3F84F-F9C4-41F7-B775-5192AFCB7007")!,
            title: "500 XP Earned",
            icon: "bolt.heart.fill",
            color: .mint,
            condition: { user in
                user.xpGainedTotal >= 500
            }
        ),
        BadgeAchievement(
            id: UUID(uuidString: "9C6DDA59-26A4-48DF-BE8C-0436B1B9D008")!,
            title: "1,000 XP Milestone",
            icon: "bolt.circle.fill",
            color: .green,
            condition: { user in
                user.xpGainedTotal >= 1000
            }
        ),
        BadgeAchievement(
            id: UUID(uuidString: "6AF7EBD1-69F7-4936-8FE0-8EAD5D1AE009")!,
            title: "10,000 XP Milestone",
            icon: "bolt.square.fill",
            color: .indigo,
            condition: { user in
                user.xpGainedTotal >= 10_000
            }
        ),
        BadgeAchievement(
            id: UUID(uuidString: "A3C0F90F-19C8-4672-B1F5-9E8C9A3F900A")!,
            title: "50,000 XP Milestone",
            icon: "bolt.horizontal.circle.fill",
            color: .purple,
            condition: { user in
                user.xpGainedTotal >= 50_000
            }
        ),

        // 🎯 Missions
        BadgeAchievement(
            id: UUID(uuidString: "D7B34C7E-431C-4FE3-885C-0B02E24E200B")!,
            title: "10 Missions Completed",
            icon: "target",
            color: .orange,
            condition: { user in
                user.stats.missionCompletedCount >= 10
            }
        ),
        BadgeAchievement(
            id: UUID(uuidString: "48E55BA1-35C0-4B9A-B395-98F16DAD400C")!,
            title: "250 Missions Completed",
            icon: "scope",
            color: .cyan,
            condition: { user in
                user.stats.missionCompletedCount >= 250
            }
        ),
        BadgeAchievement(
            id: UUID(uuidString: "7B4F93A3-8E0D-4D76-9DBE-B51CCFAFE00D")!,
            title: "500 Missions Completed",
            icon: "trophy.fill",
            color: .green,
            condition: { user in
                user.stats.missionCompletedCount >= 500
            }
        ),
        BadgeAchievement(
            id: UUID(uuidString: "3D1F7A95-6BBA-4A2B-A1C9-F91E2A06E00E")!,
            title: "10K Missions Completed",
            icon: "gamecontroller.fill",
            color: .yellow,
            condition: { user in
                user.stats.missionCompletedCount >= 10_000
            }
        ),

        // 🤝 Social & Interaction
        BadgeAchievement(
            id: UUID(uuidString: "A90C38E1-1567-45DE-9CB7-13EF2AD1E00F")!,
            title: "First Friend Added",
            icon: "person.2.fill",
            color: .blue,
            condition: { user in
                user.friends.count >= 1
            }
        ),
        BadgeAchievement(
            id: UUID(uuidString: "D6277C3D-703E-49C1-8A97-70CCB674E010")!,
            title: "3 Friends Added",
            icon: "person.3.fill",
            color: .purple,
            condition: { user in
                user.friends.count >= 3
            }
        ),
        BadgeAchievement(
            id: UUID(uuidString: "6A1B5DFE-6E9B-4A2A-9054-FC55C62EE011")!,
            title: "First Challenge Won",
            icon: "rosette",
            color: .orange,
            condition: { user in
                user.stats.challengeWonCount >= 1
            }
        ),
        BadgeAchievement(
            id: UUID(uuidString: "CE4D9A14-89F7-4E4A-8F0B-34B6D66BE012")!,
            title: "5 Challenges Won",
            icon: "rosette",
            color: .red,
            condition: { user in
                user.stats.challengeWonCount >= 5
            }
        ),
        BadgeAchievement(
            id: UUID(uuidString: "8A9E1C8A-2E57-414F-8F90-50B5729AE013")!,
            title: "50 Challenges Won",
            icon: "crown.fill",
            color: .yellow,
            condition: { user in
                user.stats.challengeWonCount >= 50
            }
        ),

        // 🧠 Mastery & Levels
        BadgeAchievement(
            id: UUID(uuidString: "1C1C9E7F-849D-4AA2-987C-1AEB582EE014")!,
            title: "Reached Level 5",
            icon: "flame.circle.fill",
            color: .orange,
            condition: { user in
                user.stats.level >= 5
            }
        ),
        BadgeAchievement(
            id: UUID(uuidString: "9D598D32-9A89-4B5C-944C-EE7A57D4E015")!,
            title: "Reached Level 10",
            icon: "trophy.circle.fill",
            color: .pink,
            condition: { user in
                user.stats.level >= 10
            }
        ),
        BadgeAchievement(
            id: UUID(uuidString: "B92FA0E1-72AE-4B4A-8E03-9F9B63A6E016")!,
            title: "Reached Level 25",
            icon: "medal.fill",
            color: .mint,
            condition: { user in
                user.stats.level >= 25
            }
        ),
        BadgeAchievement(
            id: UUID(uuidString: "EF4A26A3-9D39-4F74-9B8C-47B672ABE017")!,
            title: "Reached Level 50",
            icon: "star.circle.fill",
            color: .indigo,
            condition: { user in
                user.stats.level >= 50
            }
        ),
        BadgeAchievement(
            id: UUID(uuidString: "FBBE1437-BF28-42E3-86A0-541F1B8CE018")!,
            title: "Reached Level 75",
            icon: "wand.and.stars",
            color: .blue,
            condition: { user in
                user.stats.level >= 75
            }
        ),
        BadgeAchievement(
            id: UUID(uuidString: "AF16E1B2-0A65-43A4-AE28-29A9EE64E019")!,
            title: "Reached Level 1000",
            icon: "infinity.circle.fill",
            color: .yellow,
            condition: { user in
                user.stats.level >= 1000
            }
        )
    ]
}
