//
//  CustomViewModifiers.swift
//  LevelUp
//
//  Created by Raúl Pichardo Avalo on 9/27/25.
//

import SwiftUI

struct TapBounce: ViewModifier {
    @GestureState private var isPressed = false
    @State private var tapped = false
    
    func body(content: Content) -> some View {
        content
            .scaleEffect(isPressed ? 0.94 : (tapped ? 0.97 : 1.0))
            .animation(.spring(response: 0.25, dampingFraction: 0.7), value: isPressed)
            .animation(.spring(response: 0.25, dampingFraction: 0.7), value: tapped)
            .simultaneousGesture(
                LongPressGesture(minimumDuration: 0)
                    .updating($isPressed) { current, state, _ in
                        state = current
                    }
                    .onEnded { _ in
                        tapped = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
                            tapped = false
                        }
                    }
            )
    }
}

extension View {
    func tapBounce() -> some View {
        self.modifier(TapBounce())
    }
}
