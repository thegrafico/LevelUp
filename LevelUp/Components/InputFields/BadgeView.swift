//
//  CustomBadge.swift
//  LevelUp
//
//  Created by Raúl Pichardo Avalo on 9/28/25.
//

import SwiftUI
 
struct BadgeView: View {
    var count: Int
    var color: Color = .red
    var size: CGFloat = 18

    var body: some View {
        if count <= 0 {
            EmptyView()
        } else {
            Text(count > 99 ? "99+" : "\(count)")
                .font(.system(size: fontSize, weight: .bold, design: .rounded))
                .minimumScaleFactor(0.5) // handle 99+ gracefully
                .foregroundColor(.white)
                .frame(width: size, height: size)
                .background(color, in: Circle())
                .overlay(
                    Circle().stroke(Color.white, lineWidth: size * 0.05) // proportional stroke
                )
                .transition(.scale.combined(with: .opacity))
                .animation(.spring(response: 0.3, dampingFraction: 0.7), value: count)
        }
    }

    /// Dynamically scales text size relative to the badge
    private var fontSize: CGFloat {
        // Aim for about 55–60% of badge diameter for best readability
        return max(10, size * 0.40)
    }
}

struct BadgeBounceView: View {
    let count: Int
    let color: Color
    let size: CGFloat
    @State private var animate = false

    var body: some View {
        BadgeView(count: count, color: color, size: size)
            .scaleEffect(animate ? 1.25 : 0.9) // smaller start, bigger bounce
            .animation(.interpolatingSpring(stiffness: 250, damping: 10), value: animate)
            .onAppear {
                // 👇 delay ensures view is drawn before animating
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                    animate = true
                }
            }
            .onChange(of: animate) { _, _ in
                // 👇 re-trigger bounce on count change
                animate = false
            }
    }
}

extension View {
    func badgetOverlay(_ count: Int, color: Color = .red, alignment: Alignment = .topTrailing) -> some View {
        self.overlay(alignment: alignment) {
            BadgeView(count: count, color: color)
                .offset(x: 10, y: -15) // adjust so it “sits” nicely
        }
    }
}



#Preview {
    BadgeView(count: 5, color: .red, size: 40)
    
    BadgeBounceView(count: 5, color: .blue, size: 40)
}
