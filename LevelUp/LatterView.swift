import SwiftUI

// MARK: - Level Node with Animations
struct LevelNode: View {
    enum Status { case completed, current, locked }
    let number: Int
    let status: Status
    
    @State private var pulse = false
    @State private var showConfetti = false
    
    var body: some View {
        ZStack {
            Circle()
                .fill(circleColor)
                .frame(width: 80, height: 80)
                .overlay(
                    Text("\(number)")
                        .font(.title2.bold())
                        .foregroundColor(.white)
                )
                .scaleEffect(status == .current && pulse ? 1.15 : 1.0)
                .shadow(color: status == .current ? .green.opacity(0.7) : .clear,
                        radius: pulse ? 15 : 5)
                .onAppear {
                    if status == .current {
                        withAnimation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true)) {
                            pulse.toggle()
                        }
                    }
                }
            
            if showConfetti {
                ConfettiView()
                    .frame(width: 120, height: 120)
            }
        }
        .onChange(of: status) { _, newStatus in
            if newStatus == .completed {
                // 🎉 trigger confetti burst
                showConfetti = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    showConfetti = false
                }
            }
        }
    }
    
    private var circleColor: Color {
        switch status {
        case .completed: return .blue
        case .current: return .green
        case .locked: return .gray
        }
    }
}

// MARK: - Confetti Burst Effect
struct ConfettiView: View {
    @State private var animate = false
    
    var body: some View {
        ZStack {
            ForEach(0..<12) { i in
                Circle()
                    .fill([Color.red, .yellow, .green, .blue, .orange].randomElement()!)
                    .frame(width: 8, height: 8)
                    .offset(y: animate ? -50 : 0)
                    .rotationEffect(.degrees(Double(i) * 30))
                    .opacity(animate ? 0 : 1)
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 1.2)) {
                animate = true
            }
        }
    }
}

// MARK: - Ladder List
struct LadderListView: View {
    struct Level: Identifiable {
        let id = UUID()
        let number: Int
        var status: LevelNode.Status
    }
    
    @State private var levels: [Level] = [
        .init(number: 1, status: .completed),
        .init(number: 2, status: .completed),
        .init(number: 3, status: .current),
        .init(number: 4, status: .locked),
        .init(number: 5, status: .locked)
    ]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 50) {
                ForEach(Array(levels.enumerated()), id: \.element.id) { index, level in
                    HStack {
                        if index % 2 == 0 {
                            LevelNode(number: level.number, status: level.status)
                            Spacer()
                        } else {
                            Spacer()
                            LevelNode(number: level.number, status: level.status)
                        }
                    }
                }
            }
            .padding()
        }
        .onTapGesture {
            advanceLevel()
        }
    }
    
    private func advanceLevel() {
        // Simulate finishing current and moving forward
        if let currentIndex = levels.firstIndex(where: { $0.status == .current }) {
            levels[currentIndex].status = .completed
            if currentIndex + 1 < levels.count {
                levels[currentIndex + 1].status = .current
            }
        }
    }
}

// MARK: - Preview
#Preview {
    LadderListView()
}
