//
//  XPBadgeIcon.swift
//  LevelUp
//
//  Created by Raúl Pichardo Avalo on 9/28/25.
//

import SwiftUI

struct XPAppIcon: View {
    @Environment(\.theme) private var theme
    var size: CGFloat
    var forAppStore: Bool = false   // 👈 control square vs rounded
    
    var body: some View {
        ZStack {
            // Background
            Group {
                if forAppStore {
                    // Square (no rounded corners, no shadow)
                    Rectangle()
                        .fill(
                            LinearGradient(
                                colors: theme.brandGradient,
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                } else {
                    // Rounded + shadow (for previews inside app)
                    RoundedRectangle(cornerRadius: size * 0.43, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: theme.brandGradient,
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .shadow(color: .black.opacity(0.25),
                                radius: size * 0.04,
                                x: 0, y: size * 0.02)
                }
            }
            .frame(width: size, height: size)
            
            // Circle with XP stroke
            Circle()
                .strokeBorder(
                    LinearGradient(
                        colors: theme.brandStroke,
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: size * 0.08
                )
                .frame(width: size * 0.58, height: size * 0.58)
            
            // XP text
            Text("XP")
                .font(.system(size: size * 0.27, weight: .bold, design: .rounded))
                .foregroundColor(.white)
        }
    }
}

#Preview {
    VStack(spacing: 30) {
        XPAppIcon(size: 128) // preview rounded
            .environment(\.theme, .orange)
        
        XPAppIcon(size: 430, forAppStore: true) // export-ready square
            .environment(\.theme, .blue)
    }
}
