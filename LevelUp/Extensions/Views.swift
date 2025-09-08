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

