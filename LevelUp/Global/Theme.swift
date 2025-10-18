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
    let cornerRadiusMedium: CGFloat
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
        cornerRadiusMedium: 16,
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
        cornerRadiusMedium: 16,
        cornerRadiusLarge: 20,
        
        titleFont: .system(.title2, design: .rounded).weight(.bold),
        bodyFont: .system(.body, design: .rounded),

        brandGradient: [Color.blue, Color.purple],
        brandStroke: [Color.white.opacity(0.9), Color.cyan.opacity(0.9)]
    )
    
    static let dark = Theme(
            primary: Color(red: 1.0, green: 0.45, blue: 0.2), // 🔶 Warm orange highlight
            accent: Color(red: 1.0, green: 0.75, blue: 0.35), // 🟡 Golden accent
            background: Color(red: 0.05, green: 0.05, blue: 0.07), // near-black matte
            cardBackground: Color(red: 0.12, green: 0.12, blue: 0.15), // subtle lifted panels
            
            textPrimary: Color.white.opacity(0.95),
            textSecondary: Color.white.opacity(0.65),
            textBlack: .white,
            textInverse: .black,
            
            shadowLight: Color.white.opacity(0.05), // inner glow feel
            shadowDark: Color.black.opacity(0.8),   // outer shadow for contrast
            
            cornerRadiusSmall: 12,
            cornerRadiusMedium: 18,
            cornerRadiusLarge: 24,
            
            titleFont: .system(.title2, design: .rounded).weight(.bold),
            bodyFont: .system(.body, design: .rounded),
            
            // 🌈 Brand gradient (signature LevelUp glow)
            brandGradient: [
                Color(red: 1.0, green: 0.5, blue: 0.15), // orange core
                Color(red: 0.9, green: 0.2, blue: 0.5),  // magenta fusion
                Color(red: 0.2, green: 0.6, blue: 1.0)   // electric blue tail
            ],
            
            // ✨ Gradient stroke for cards or rings
            brandStroke: [
                Color.white.opacity(0.85),
                Color.orange.opacity(0.8),
                Color.pink.opacity(0.7)
            ]
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
