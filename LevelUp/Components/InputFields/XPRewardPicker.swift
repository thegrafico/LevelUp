//
//  XPRewardPicker.swift
//  LevelUp
//
//  Created by Raúl Pichardo Avalo on 9/26/25.
//

import SwiftUI

struct XPRewardPicker: View {

    @Binding var selectedXP: Int
    @Environment(\.theme) private var theme
    
    var body: some View {
        Section("XP Reward") {
            LazyVGrid(
                columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 4),
                spacing: 12
            ) {
                ForEach(Mission.xpValues, id: \.self) { value in
                    let isSelected = selectedXP == value
                    Text("\(value)")
                        .font(.subheadline.weight(.semibold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(
                            RoundedRectangle(cornerRadius: theme.cornerRadiusSmall, style: .continuous)
                                .fill(isSelected ? theme.primary : theme.cardBackground)
                        )
                        .foregroundStyle(isSelected ? theme.textInverse : theme.textPrimary)
                        .overlay(
                            RoundedRectangle(cornerRadius: theme.cornerRadiusSmall, style: .continuous)
                                .stroke(theme.textSecondary.opacity(0.2), lineWidth: isSelected ? 0 : 1)
                        )
                        .onTapGesture { selectedXP = value }
                }
            }
            .padding(.vertical, 4)
        }
    }
}

#Preview {
    XPRewardPicker(selectedXP: .constant(Mission.xpValues.first!))
}
