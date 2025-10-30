//
//  MissionPreviewViewExtension.swift
//  LevelUp
//
//  Created by Raúl Pichardo Avalo on 10/29/25.
//

import SwiftUI



struct EditableXPView: View {
    @Environment(\.theme) private var theme
    @Bindable var mission: Mission
    
    @State private var isEditingXP = false
    @State private var lastValidXP: Int = 0
    @State private var showXPWarning = false
    
    private let allowedXPValues = [10, 15, 20, 25]
    
    var body: some View {
        ZStack {
            if isEditingXP {
                HStack(spacing: 8) {
                    ForEach(allowedXPValues, id: \.self) { xpValue in
                        Text("\(xpValue)")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(
                                mission.xp == xpValue ? theme.textInverse : theme.textPrimary
                            )
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(mission.xp == xpValue ? theme.primary : theme.cardBackground)
                            )
                            .onTapGesture {
                                withAnimation(.easeInOut) {
                                    mission.xp = xpValue
                                    isEditingXP = false
                                }
                                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                            }
                    }
                }
                .transition(.scale.combined(with: .opacity))
            } else {
                Label("\(mission.xp) XP", systemImage: "bolt.fill")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(theme.primary)
                    .onTapGesture {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                            lastValidXP = mission.xp
                            isEditingXP = true
                        }
                    }
            }
        }
        .onChange(of: isEditingXP) { _, editing in
            if !editing {
                // Validate XP in case user cancels out somehow
                if !allowedXPValues.contains(mission.xp) {
                    mission.xp = lastValidXP
                    showXPWarning = true
                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                        withAnimation { showXPWarning = false }
                    }
                }
            }
        }
        .overlay(
            Group {
                if showXPWarning {
                    Text("⚠️ Invalid XP reverted")
                        .font(.caption2.weight(.semibold))
                        .foregroundStyle(.red)
                        .transition(.opacity)
                        .offset(y: -24)
                }
            }
        )
    }
}
