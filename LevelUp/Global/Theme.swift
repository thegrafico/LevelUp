//
//  Theme.swift
//  LevelUp
//
//  Created by Raúl Pichardo Avalo on 9/8/25.
//

import Foundation
import SwiftUI

struct Theme {
    // Core colors
    let primary: Color
    let accent: Color
    let background: Color
    let cardBackground: Color
    
    // Text
    let textPrimary: Color
    let textSecondary: Color
    let textBlack: Color
    let textInverse: Color
    
    // Surfaces / shadows
    let shadowLight: Color
    let shadowDark: Color
    
    // Radii
    let cornerRadiusSmall: CGFloat
    let cornerRadiusLarge: CGFloat
    
    // Typography
    let titleFont: Font
    let bodyFont: Font

    // 🎯 Brand / Icon Colors
    let brandGradient: [Color]
    let brandStroke: [Color]
}

extension Theme {
    static let orange = Theme(
        primary: .orange,
        accent: .yellow,
        background: Color(.systemGroupedBackground),
        cardBackground: .white,
        
        textPrimary: .primary,
        textSecondary: .black,
        textBlack: .black,
        textInverse: .white,
        
        shadowLight: .black.opacity(0.06),
        shadowDark: .black.opacity(0.14),
        
        cornerRadiusSmall: 12,
        cornerRadiusLarge: 20,
        
        titleFont: .system(.title2, design: .rounded).weight(.bold),
        bodyFont: .system(.body, design: .rounded),

        brandGradient: [Color.orange, Color(red: 1.0, green: 0.5, blue: 0.0)],
        brandStroke: [Color.white.opacity(0.9), Color.yellow.opacity(0.9)]
    )

    static let blue = Theme(
        primary: .blue,
        accent: .mint,
        background: Color(.systemGroupedBackground),
        cardBackground: .white,
        
        textPrimary: .primary,
        textSecondary: .secondary,
        textBlack: .black,
        textInverse: .white,
        
        shadowLight: .black.opacity(0.05),
        shadowDark: .black.opacity(0.2),
        
        cornerRadiusSmall: 12,
        cornerRadiusLarge: 20,
        
        titleFont: .system(.title2, design: .rounded).weight(.bold),
        bodyFont: .system(.body, design: .rounded),

        brandGradient: [Color.blue, Color.purple],
        brandStroke: [Color.white.opacity(0.9), Color.cyan.opacity(0.9)]
    )
}

private struct ThemeKey: EnvironmentKey {
    static let defaultValue: Theme = .orange
}

extension EnvironmentValues {
    var theme: Theme {
        get { self[ThemeKey.self] }
        set { self[ThemeKey.self] = newValue }
    }
}
