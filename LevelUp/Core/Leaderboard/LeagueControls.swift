//
//  LeagueControls.swift
//  LevelUp
//
//  Created by Raúl Pichardo Avalo on 9/9/25.
//

import SwiftUI

enum LeagueTimePeriod: String, CaseIterable, Identifiable {
    case currentWeek = "This Week"
    case lastWeek    = "Last Week"
    var id: Self { self }
}

enum LeagueType: String, CaseIterable, Identifiable {
    case gold       = "Gold"
    case silver     = "Silver"
    case bronze     = "Bronze"
    case none       = "none"
    var id: Self { self }
}

// MARK: - League Controls (chips)
struct LeagueControls: View {
    @Environment(\.theme) private var theme

    @Binding var selectedPeriod: LeagueTimePeriod
    @Binding var selectedLeague: LeagueType

    var body: some View {
        VStack(spacing: 12) {
            HStack(spacing: 8) {
                ForEach(LeagueTimePeriod.allCases) { period in
                    let isSel = selectedPeriod == period
                    Text(period.rawValue)
                        .font(.footnote.weight(.semibold))
                        .foregroundStyle(isSel ? theme.textInverse : theme.textPrimary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: theme.cornerRadiusSmall, style: .continuous)
                                .fill(isSel ? theme.primary : theme.cardBackground)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: theme.cornerRadiusSmall, style: .continuous)
                                .stroke(theme.textPrimary.opacity(0.08), lineWidth: isSel ? 0 : 1)
                        )
                        .onTapGesture { selectedPeriod = period }
                }
            }
            .elevatedCard(corner: theme.cornerRadiusLarge)
            .background(theme.background)
        }
    }
}


#Preview {
    LeagueControls(
        selectedPeriod: .constant(.currentWeek),
        selectedLeague: .constant(.gold))        
}
