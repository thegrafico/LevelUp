//
//  Views.swift
//  LevelUp
//
//  Created by Raúl Pichardo Avalo on 9/6/25.
//

import Foundation
import SwiftUI

struct ElevatedCard: ViewModifier {
    @Environment(\.theme) private var theme
    var corner: CGFloat?

    func body(content: Content) -> some View {
        content
            .background(theme.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: corner ?? theme.cornerRadiusLarge, style: .continuous))
            .shadow(color: theme.shadowLight, radius: 8, y: 4)
            .shadow(color: theme.shadowDark, radius: 18, y: 12)
    }
}
extension View {
    func elevatedCard(corner: CGFloat? = nil) -> some View {
        self.modifier(ElevatedCard(corner: corner))
    }
}



extension ButtonStyle where Self == ScaleOnTapButtonStyle {
    static var scaleOnTap: ScaleOnTapButtonStyle { ScaleOnTapButtonStyle() }
}

struct ScaleOnTapButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: configuration.isPressed)
    }
}
