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

    var isGlobal: Bool {
        mission.type == .global
    }

    var body: some View {
        ZStack {
            // Base row content
            HStack(spacing: 14) {
                // Icon
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
                    
                    HStack {
                        
                        Text("+\(mission.xp) XP")
                            .font(.subheadline).monospaced()
                            .foregroundStyle(theme.primary)
                        
                        if isGlobal {
                            Image(systemName: "globe.americas.fill")
                                .font(.system(size: 16))
                                .foregroundStyle(theme.primary.opacity(0.5))
                                .allowsHitTesting(false)  // so it doesn’t interfere with taps
                        }
                        
                        if mission.isNew {
                            Text("NEW")
                                .font(.caption2.weight(.bold))
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(theme.accent.opacity(0.2))
                                .foregroundStyle(theme.accent)
                                .clipShape(Capsule())

                        }
                    }
                }

                Spacer()

                // Circle toggle button
                Button {
                    let h = UIImpactFeedbackGenerator(style: .soft)
                    h.impactOccurred()
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
                        mission.isSelected.toggle()
                    }
                } label: {
                    ZStack {
                        Circle()
                            .fill(Color.black.opacity(0.06))
                            .frame(width: 36, height: 36)
                        if mission.isSelected {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(theme.primary)
                                .transition(.scale.combined(with: .opacity))
                                .font(.title)
                        }
                    }
                    .frame(width: 60, height: 44)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
            .padding(16)
            .elevatedCard(corner: 18)
        }
    }
}
#Preview {
    
    MissionRow(mission: Mission.SampleLocalMissions.first!)
        .environment(\.theme, .orange)
    
    MissionRow(mission: Mission.sampleGlobalMissions.first!)
        .environment(\.theme, .orange)
}
