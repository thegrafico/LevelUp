//
//  FloatingPopUp.swift
//  LevelUp
//
//  Created by Raúl Pichardo Avalo on 9/27/25.
//

import SwiftUI

struct FloatingPopup: View {
    @State private var show = false
    @State private var scale: CGFloat = 0.8
    @Environment(\.theme) private var theme
    
    var duration: Double = 3.0
    var text: String = "+1 Mission"
    var baseColor: Color? = nil
    
    var activeColor : Color {
        baseColor ?? theme.primary
    }
    
    var body: some View {
        Text(text)
            .font(.system(size: 28, weight: .black, design: .rounded))
            .overlay(
                LinearGradient(
                    colors: [activeColor, activeColor.opacity(0.8)], // dynamic gradient
                    startPoint: .top,
                    endPoint: .bottom
                )
                .mask(
                    Text(text)
                        .font(.system(size: 28, weight: .black, design: .rounded))
                )
            )
            // dynamic glow
            .shadow(color: activeColor.opacity(0.8), radius: 12, x: 0, y: 0)
            .shadow(color: .white.opacity(0.6), radius: 4, x: 0, y: 0)
            .opacity(show ? 0 : 1)
            .offset(y: show ? -100 : 0)
            .scaleEffect(scale)
            .onAppear {
                withAnimation(.spring(response: 0.25, dampingFraction: 0.4)) {
                    scale = 1.3
                }
                withAnimation(.spring(response: 0.25, dampingFraction: 0.7).delay(0.2)) {
                    scale = 1.0
                }
                withAnimation(.easeOut(duration: duration).delay(0.2)) {
                    show = true
                }
            }
    }
}
#Preview {
    VStack {
        ZStack {
            HStack {
                FloatingPopup(duration: 3)
                FloatingPopup(duration: 5, baseColor: .red)
            }
        }
    }
    
    .environment(\.theme, .orange)
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .ignoresSafeArea()
}
