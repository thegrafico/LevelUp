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
                .font(.caption2.bold())
                .foregroundColor(.white)
                .frame(width: size, height: size)
                .background(color, in: Circle())
                .overlay(
                    Circle().stroke(Color.white, lineWidth: 1)
                )
                .transition(.scale.combined(with: .opacity))
                .animation(.spring(response: 0.3, dampingFraction: 0.7), value: count)
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
}
