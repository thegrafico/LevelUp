//
//  MissionFilterChips.swift
//  LevelUp
//
//  Created by Raúl Pichardo Avalo on 9/26/25.
//

import SwiftUI

struct MissionFilterChips: View {
    @Environment(\.theme) private var theme
    @Binding var selectedFilter: MissionFilter

    var body: some View {
        HStack{
            ForEach(MissionFilter.allCases) { filter in
                let isSelected = selectedFilter == filter
                Text(filter.rawValue)
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(isSelected ? theme.textInverse : theme.textPrimary)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: theme.cornerRadiusSmall, style: .continuous)
                            .fill(isSelected ? theme.primary : theme.cardBackground)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: theme.cornerRadiusSmall, style: .continuous)
                            .stroke(theme.textPrimary.opacity(0.08), lineWidth: isSelected ? 0 : 1)
                    )
                    .onTapGesture { selectedFilter = filter }
            }
        }
    }
}

#Preview {
    MissionFilterChips(selectedFilter: .constant(.custom))
    MissionFilterChips(selectedFilter: .constant(.global))
    MissionFilterChips(selectedFilter: .constant(.all))
}
