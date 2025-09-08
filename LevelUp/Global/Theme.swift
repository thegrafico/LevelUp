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
    
    // Radi
    let cornerRadiusSmall: CGFloat
    let cornerRadiusLarge: CGFloat
    
    // Typography (you can expand later if needed)
    let titleFont: Font
    let bodyFont: Font
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
        bodyFont: .system(.body, design: .rounded)
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
        bodyFont: .system(.body, design: .rounded)
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
