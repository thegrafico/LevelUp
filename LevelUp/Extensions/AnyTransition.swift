//
//  AnyTransition.swift
//  LevelUp
//
//  Created by Raúl Pichardo Avalo on 9/28/25.
//

import Foundation
import SwiftUI

extension AnyTransition {
    
    // MARK: - Simple Custom Transitions
    
    static var fadeRightToLeft: AnyTransition {
        .asymmetric(
            insertion: .opacity.combined(with: .move(edge: .trailing)),
            removal: .opacity.combined(with: .move(edge: .leading))
        )
    }
    
    static var flipAway: AnyTransition {
        .modifier(
            active: FlipAwayModifier(),
            identity: FlipAwayModifier(reset: true)
        )
    }
    
    static var explosion: AnyTransition {
        asymmetric(
            insertion: .opacity,
            removal: .scale(scale: 1.3).combined(with: .opacity)
        )
    }
    
    static var pixelate: AnyTransition {
        .modifier(
            active: PixelateModifier(),
            identity: PixelateModifier(reset: true)
        )
    }
    
    static var blurOut: AnyTransition {
        .modifier(
            active: BlurModifier(),
            identity: BlurModifier(reset: true)
        )
    }
    
    static var spinOut: AnyTransition {
        .modifier(
            active: SpinModifier(),
            identity: SpinModifier(reset: true)
        )
    }
}

struct FlipAwayModifier: ViewModifier {
    var reset = false
    func body(content: Content) -> some View {
        content
            .rotation3DEffect(
                .degrees(reset ? 0 : 90),
                axis: (x: 0, y: 1, z: 0)
            )
            .opacity(reset ? 1 : 0)
    }
}

struct PixelateModifier: ViewModifier {
    var reset = false
    func body(content: Content) -> some View {
        content
            .blur(radius: reset ? 0 : 10)
            .saturation(reset ? 1 : 0.1)
    }
}

struct BlurModifier: ViewModifier {
    var reset = false
    func body(content: Content) -> some View {
        content.blur(radius: reset ? 0 : 8)
    }
}

struct SpinModifier: ViewModifier {
    var reset = false
    func body(content: Content) -> some View {
        content.rotationEffect(.degrees(reset ? 0 : 720))
    }
}
