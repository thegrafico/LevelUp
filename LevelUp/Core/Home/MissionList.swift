//
//  MissionList.swift
//  LevelUp
//
//  Created by Raúl Pichardo Avalo on 9/6/25.
//
//
//  MissionList.swift
//  LevelUp
//
//  Created by Raúl Pichardo Avalo on 9/6/25.
//
import SwiftUI

// MARK: - Mission Filter
enum MissionFilter: String, CaseIterable, Identifiable {
    case custom = "My Missions"
    case global = "Global"
    case all = "All"
    var id: String { rawValue }
}

// MARK: - Section
struct MissionList: View {
    @Environment(\.theme) private var theme
    @Binding var missions: [Mission]

    // later: global missions could come from SwiftData
    private let globalMissions: [Mission] = Mission.sampleData

    @State private var selectedFilter: MissionFilter = .custom

    // Filtered list
    private var filteredMissions: [Mission] {
        switch selectedFilter {
        case .all:
            return globalMissions + missions
        case .global:
            return globalMissions
        case .custom:
            return missions
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Daily Missions")
                .font(.title3.weight(.bold))
                .padding(.horizontal, 20)

            // MARK: Filter Chips
            HStack(spacing: 8) {
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
            .padding(.bottom, 10)
            .padding(.horizontal, 20)
            

            // MARK: Mission List
            ScrollView {
                VStack(spacing: 16) {
                    ForEach(filteredMissions, id: \.id) { mission in
                        MissionRow(mission: .constant(mission))
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
        }
    }
}

// MARK: - Preview (UI-only)
#Preview {
    ScrollView {
        VStack(spacing: 16) {
            MissionList(missions: .constant(Mission.sampleData))
        }
        .padding(.vertical, 20)
    }
    .environment(\.theme, .orange)
}
