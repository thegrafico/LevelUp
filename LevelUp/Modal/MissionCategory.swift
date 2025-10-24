//
//  MissionCategory.swift
//  LevelUp
//
//  Created by Raúl Pichardo Avalo on 10/23/25.
//

import Foundation
import SwiftData

// MARK: - Custom Category
struct CustomCategory: Codable, Equatable, Hashable {
    var name: String
    
    func hash(into hasher: inout Hasher) {
           hasher.combine(name.lowercased()) // only hash name, case-insensitive
       }

    
    static func == (lhs: CustomCategory, rhs: CustomCategory) -> Bool {
       lhs.name.lowercased() == rhs.name.lowercased()
    }
//    var colorHex: String?
}

// MARK: - Mission Category Enum
enum MissionCategory: Codable, Equatable, Identifiable, Hashable {
    case general
    case morning
    case afternoon
    case noon
    case saitama
    case custom(CustomCategory)
    
    var id: String { name }
    
    var name: String {
        switch self {
        case .general: return "General"
        case .morning: return "Morning 🌥️"
        case .afternoon: return "Afternoon ☀️"
        case .noon: return "Noon 🌙"
        case .saitama: return "Saitama 💪"
        case .custom(let custom): return custom.name
        }
    }
    
//    var colorHex: String {
//        switch self {
//        case .general: return "#8E8E93"
//        case .
//        case .saitama: return "#FFD700"
//        case .custom(let custom): return custom.colorHex ?? "#8E8E93"
//        }
//    }
}
