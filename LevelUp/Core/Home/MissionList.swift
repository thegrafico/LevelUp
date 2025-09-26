import SwiftUI


// MARK: - Section
struct MissionList: View {
    @Environment(\.theme) private var theme
    
    // MARK: Missions
    @Binding var customMissions: [Mission]
    @Binding var globalMissions: [Mission]
    
    // MARK: Filters
    @State private var selectedFilter: MissionFilter = .global
    @State private var selectedSort: MissionSort = .name
        
    private var filteredMissions: [Mission] {
        let base: [Mission]
        
        switch selectedFilter {
            case .all: base = globalMissions + customMissions
            case .global: base = globalMissions
            case .custom: base = customMissions
        }
        
        // Sort applied on top
        switch selectedSort {
            case .name:
                return base.sorted { $0.title < $1.title }
            case .xpAscending:
                return base.sorted { $0.xp < $1.xp }
            case .xpDescending:
                return base.sorted { $0.xp > $1.xp }
            case .completed:
                return base.sorted { $0.completed && !$1.completed }
            case .creationDateAscending:
                return base.sorted { $0.createdAt > $1.createdAt }
            case .creationDateDescending:
                return base.sorted { $0.createdAt < $1.createdAt }
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // MARK: Header Row
            HStack {
                Text("Daily Missions")
                    .font(.title3.weight(.bold))
            }
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
                
                Spacer()
                
                // Sort menu
                Menu {
                    ForEach(MissionSort.allCases) { sort in
                        Button {
                            selectedSort = sort
                        } label: {
                            HStack {
                                Text(sort.rawValue)
                                if selectedSort == sort {
                                    Image(systemName: "checkmark")
                                }
                            }
                        }
                    }
                } label: {
                    Label("Sort", systemImage: "arrow.up.arrow.down")
                        .labelStyle(.iconOnly)
                        .font(.title3)
                        .foregroundStyle(theme.primary)
                }
            }
            .padding(.horizontal, 20)
            
            // MARK: List of missions
            ScrollView {
                VStack(spacing: 16) {
                    if !filteredMissions.isEmpty {
                        ForEach(filteredMissions, id: \.id) { mission in
                            MissionRow(mission: .constant(mission))
                        }
                    } else {
                        ContentUnavailableView("Add Mission", systemImage: "list.bullet.circle.fill")
                            .fontWeight(.semibold)
                            .opacity(0.5)
                            .padding(.top, 30)
                    }
                    
                }
                .padding(.top, 16)
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
        }
    }
}


#Preview {
    ScrollView {
        VStack(spacing: 16) {
            MissionList(
                customMissions: .constant(Mission.sampleData),
                globalMissions: .constant(Mission.sampleGlobalMissions)
            )
        }
        .padding(.vertical, 20)
    }
    .environment(\.theme, .orange)
}
