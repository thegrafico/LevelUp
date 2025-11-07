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
    var canEdit: Bool = false
    
    @State private var isEditingXP = false
    @State private var lastValidXP: Int = 0
    @State private var showXPWarning = false
    @State private var deniedEdit = false
    @State private var shakeOffset: CGFloat = 0
    
    private let allowedXPValues = [10, 15, 20, 25]
    
    var body: some View {
        ZStack {
            if isEditingXP {
                HStack(spacing: 8) {
                    ForEach(allowedXPValues, id: \.self) { xpValue in
                        Text("\(xpValue)")
                            .font(.caption2.weight(.semibold))
                            .foregroundStyle(
                                mission.xp == xpValue ? theme.textInverse : theme.textPrimary
                            )
                            .lineLimit(1)
                            .fixedSize()
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
                    .foregroundStyle(deniedEdit ? .red : theme.primary)
                    .lineLimit(1)
                    .fixedSize()
                    .offset(x: shakeOffset)
                    .onTapGesture {
                        if canEdit {
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                lastValidXP = mission.xp
                                isEditingXP = true
                            }
                        } else {
                            triggerDeniedFeedback(active: $deniedEdit, offset: $shakeOffset)
                        }
                    }
            }
        }
    }
}
