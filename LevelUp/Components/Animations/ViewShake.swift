//
//  ViewShake.swift
//  LevelUp
//
//  Created by Raúl Pichardo Avalo on 11/2/25.
//

import SwiftUI

struct DeniedEditEffect: ViewModifier {
    @Binding var active: Bool
    @Binding var shakeOffset: CGFloat
    var baseColor: Color
    var deniedColor: Color = .red

    func body(content: Content) -> some View {
        content
            .foregroundStyle(active ? deniedColor : baseColor)
            .offset(x: shakeOffset)
            .animation(.easeInOut(duration: 0.2), value: active)
    }
}

extension View {
    func deniedEditEffect(active: Binding<Bool>, offset: Binding<CGFloat>, baseColor: Color, deniedColor: Color = .red) -> some View {
        self.modifier(DeniedEditEffect(active: active, shakeOffset: offset, baseColor: baseColor, deniedColor: deniedColor))
    }
}
