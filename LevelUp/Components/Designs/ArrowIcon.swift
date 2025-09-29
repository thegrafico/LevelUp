import SwiftUI

struct ArrowAppIcon: View {
    var body: some View {
        ZStack {
            // Background rounded square
            RoundedRectangle(cornerRadius: 220, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [Color.orange, Color(red: 1.0, green: 0.45, blue: 0.0)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 512, height: 512)
                .shadow(color: .black.opacity(0.25), radius: 20, x: 0, y: 10)
            
            // Glassy inner highlight (radial gradient)
            Circle()
                .fill(
                    RadialGradient(
                        gradient: Gradient(colors: [
                            .white.opacity(0.35),
                            .white.opacity(0.05),
                            .clear
                        ]),
                        center: .center,
                        startRadius: 40,
                        endRadius: 180
                    )
                )
                .frame(width: 330, height: 330)
                .overlay(
                    Circle()
                        .stroke(.white.opacity(0.25), lineWidth: 6)
                )
                .blur(radius: 4)
            
            // Top shine arc (glass reflection)
            Circle()
                .trim(from: 0.0, to: 0.5)
                .stroke(
                    LinearGradient(
                        colors: [.white.opacity(0.6), .clear],
                        startPoint: .top,
                        endPoint: .bottom
                    ),
                    style: StrokeStyle(lineWidth: 16, lineCap: .round)
                )
                .rotationEffect(.degrees(-20))
                .frame(width: 260, height: 260)
                .opacity(0.7)
            
            // Thicker arrow shape
            ArrowShape()
                .fill(Color.white)
                .frame(width: 220, height: 220)
                .shadow(color: .black.opacity(0.25), radius: 8, x: 0, y: 4)
        }
    }
}

// MARK: - Custom Arrow Shape
struct ArrowShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let w = rect.width
        let h = rect.height
        path.move(to: CGPoint(x: w/2, y: 0))               // top center
        path.addLine(to: CGPoint(x: w, y: h * 0.55))       // right mid
        path.addLine(to: CGPoint(x: w * 0.65, y: h * 0.55))
        path.addLine(to: CGPoint(x: w * 0.65, y: h))       // stem right
        path.addLine(to: CGPoint(x: w * 0.35, y: h))       // stem left
        path.addLine(to: CGPoint(x: w * 0.35, y: h * 0.55))
        path.addLine(to: CGPoint(x: 0, y: h * 0.55))       // left mid
        path.closeSubpath()
        return path
    }
}

#Preview {
    ArrowAppIcon()
}
