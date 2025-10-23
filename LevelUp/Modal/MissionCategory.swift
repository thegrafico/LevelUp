//
//  MissionCategory.swift
//  LevelUp
//
//  Created by Raúl Pichardo Avalo on 10/23/25.
//

import Foundation
import SwiftData

// MARK: - Custom Category
struct CustomCategory: Codable, Equatable {
    var name: String
    var colorHex: String?
}

// MARK: - Mission Category Enum
enum MissionCategory: Codable, Equatable, Identifiable {
    case general
    case training
    case saitama
    case custom(CustomCategory)
    
    var id: String { name }
    
    var name: String {
        switch self {
        case .general: return "General"
        case .training: return "Training"
        case .saitama: return "Saitama"
        case .custom(let custom): return custom.name
        }
    }
    
    var colorHex: String {
        switch self {
        case .general: return "#8E8E93"
        case .training: return "#34C759"
        case .saitama: return "#FFD700"
        case .custom(let custom): return custom.colorHex ?? "#8E8E93"
        }
    }
}
