//
//  ThemeOption.swift
//  LevelUp
//
//  Created by Raúl Pichardo Avalo on 10/30/25.
//

import Foundation
import SwiftUI

/// Represents the user's theme preference
enum ThemeOption: String, CaseIterable, Identifiable {
    case system
    case orange
    case blue
    case dark

    var id: String { rawValue }

    /// Resolves to a concrete `Theme`
    func resolve(using colorScheme: ColorScheme?) -> Theme {
        switch self {
        case .orange:
            return .orange
        case .blue:
            return .blue
        case .dark:
            return .dark
        case .system:
            // auto-detect based on device appearance
            if colorScheme == .dark {
                return .dark
            } else {
                return .orange
            }
        }
    }

    var displayName: String {
        switch self {
        case .system: return "System"
        case .orange: return "Orange"
        case .blue:   return "Blue"
        case .dark:   return "Dark"
        }
    }
}
