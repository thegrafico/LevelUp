import SwiftUI


// MARK: - Section
struct MissionList: View {
    @Environment(\.theme) private var theme
    
    // MARK: Missions
    var customMissions: [Mission]
    var globalMissions: [Mission]
    
    init(_ customMissions: [Mission], _ globalMissions: [Mission]) {
        self.customMissions = customMissions
        self.globalMissions = globalMissions
    }
    
    
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
                
                MissionFilterChips(selectedFilter: $selectedFilter)
                
                Spacer()
                
                if selectedFilter == .custom {
                   Button {
                       // delete action
                   } label: {
                       Image(systemName: "trash.fill")
                           .font(.title3)
                           .symbolRenderingMode(.hierarchical)
                           .foregroundStyle(theme.primary)
                           .opacity(filteredMissions.contains(where: {$0.isSelected && $0.type == .custom}) ? 1 : 0.3)
                           .symbolEffect(.bounce, value: selectedFilter == .custom) // fun pop on appear
                   }
                   .disabled(filteredMissions.contains(where: {$0.isSelected && $0.type == .custom}))
                   .transition(.asymmetric(
                       insertion: .move(edge: .trailing).combined(with: .opacity),
                       removal:  .scale(scale: 0.7).combined(with: .opacity)
                   ))
                   .id("trash")
                }

                
                // MARK: SORT
                MissionSortMenu(selectedSort: $selectedSort)
                
            }.animation(.spring(response: 0.35, dampingFraction: 0.82), value: selectedFilter)
                .padding(.horizontal, 20)
            .padding(.horizontal, 20)
            
            // MARK: List of missions
            ScrollView {
                VStack(spacing: 16) {
                    if !filteredMissions.isEmpty {
                        ForEach(filteredMissions, id: \.id) { mission in
                            Button {
                                let h = UIImpactFeedbackGenerator(style: .rigid); h.impactOccurred()
                                    print("Tapped: \(mission.title)")
                                } label: {
                                    MissionRow(mission: mission)
                                }
                            
                                .buttonStyle(TapBounceStyle()) // 👈 new style
                            
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
                Mission.sampleData,
                Mission.sampleGlobalMissions
            )
        }
        .padding(.vertical, 20)
    }
    .environment(\.theme, .orange)
}
