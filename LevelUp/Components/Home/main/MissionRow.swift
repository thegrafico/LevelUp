//
//  MissionRow.swift
//  LevelUp
//
//  Created by Raúl Pichardo Avalo on 9/6/25.
//

import SwiftUI

struct MissionRow: View {
    @Environment(\.theme) var theme
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
                        .fill(theme.primary.opacity(0.12))
                        .frame(width: 48, height: 48)
                    Image(systemName: mission.icon)
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundStyle(theme.primary)
                }

                VStack(alignment: .leading, spacing: 2) {
                    
                    Text(mission.title)
                        .font(.headline.weight(.semibold))
                        .foregroundStyle(theme.textBlack.opacity(0.7))
                    
                    Text("+\(mission.xp) XP")
                        .font(.subheadline).monospaced()
                        .foregroundStyle(theme.primary)
                }

                Spacer()

                ZStack {
                    Circle().fill(.black.opacity(0.06)).frame(width: 36, height: 36)
                    if mission.completed {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(theme.primary)
                            .transition(.scale.combined(with: .opacity))
                            .font(.title)
                    }
                }
            }
            .foregroundStyle(theme.primary)
            .padding(16)
            .contentShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        }
        .buttonStyle(PressableCardStyleThemed())
        .elevatedCard(corner: 18)
    }
}

#Preview {
    MissionRow(mission: Mission.sampleData[0], onToggle: {_ in })
        .environment(\.theme, .orange)
}
