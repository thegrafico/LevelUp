//
//  MissionFilterChips.swift
//  LevelUp
//
//  Created by Raúl Pichardo Avalo on 9/26/25.
//

import SwiftUI

struct MissionFilterChips: View {
    @Environment(\.theme) private var theme
    @Environment(BadgeManager.self) private var badgeManager: BadgeManager?
    @Binding var selectedFilter: MissionType

    var body: some View {
        HStack{
            ForEach(MissionType.allCases) { filter in
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
                    .overlay(alignment: .topTrailing) {
                        if let badgeManager = badgeManager {
                            
                            let count = badgeManager.count(for: .filter(filter))
                            if count > 0 {
                                BadgeView(count: count, size: 20)
                                    .offset(x: 8, y: -8)
                            } else {
                                EmptyView()
                            }
                        }
                    }.onTapGesture { selectedFilter = filter }
                    
            }
        }
    }
}

#Preview {
    MissionFilterChips(selectedFilter: .constant(.custom))        .environment(BadgeManager(defaultCount: 20)) // 👈 inject once


    MissionFilterChips(selectedFilter: .constant(.global))
        .environment(BadgeManager()) // 👈 inject once

}
