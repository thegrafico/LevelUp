//
//  MissionRow.swift
//  LevelUp
//
//  Created by Raúl Pichardo Avalo on 9/6/25.
//

import SwiftUI

struct MissionRow: View {
    @Bindable var mission: Mission
    var onToggle: (Mission) -> Void

    var body: some View {
        Button {
            let h = UIImpactFeedbackGenerator(style: .soft); h.impactOccurred()
            withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
                mission.completed.toggle()
                onToggle(mission)
            }
        } label: {
            HStack(spacing: 14) {
                // Icono
                ZStack {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(.orange.opacity(0.12))
                        .frame(width: 48, height: 48)
                    Image(systemName: mission.icon)
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundStyle(.orange)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(mission.title)
                        .font(.headline.weight(.semibold))
                    Text("+\(mission.xp) XP")
                        .font(.subheadline).monospaced()
                        .foregroundStyle(.orange)
                }

                Spacer()

                ZStack {
                    Circle().fill(.black.opacity(0.06)).frame(width: 36, height: 36)
                    if mission.completed {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(.orange)
                            .transition(.scale.combined(with: .opacity))
                            .font(.title)
                    }
                }
            }
            .padding(16)
            .contentShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        }
        .buttonStyle(PressableCardStyle())
        .elevatedCard(corner: 18)
    }
}

#Preview {
    MissionRow(mission: Mission.sampleData[0], onToggle: {_ in })
}
