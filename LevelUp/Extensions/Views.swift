//
//  Views.swift
//  LevelUp
//
//  Created by Raúl Pichardo Avalo on 9/6/25.
//

import Foundation
import SwiftUI

extension View {
    func elevatedCard(corner: CGFloat = 16) -> some View {
        self
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: corner, style: .continuous))
            // subtle glossy edge
            .overlay(
                RoundedRectangle(cornerRadius: corner, style: .continuous)
                    .strokeBorder(.white.opacity(0.5), lineWidth: 1)
                    .blendMode(.overlay)
            )
            // layered shadows = depth
            .shadow(color: .black.opacity(0.06), radius: 8, y: 4)
            .shadow(color: .black.opacity(0.14), radius: 22, y: 16)
    }
}

