import SwiftUI


// MARK: - Section
struct MissionList: View {
    @Environment(\.theme) private var theme
    @Environment(\.modelContext) private var context

    private var missionController: MissionController {
        MissionController(context: context)
    }
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
    @State private var showDeleteConfirmation = false
        
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
    
    private var selectedCustomMissions: [Mission] {
        customMissions.filter { $0.isSelected }
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
                       showDeleteConfirmation = true
                   } label: {
                       Image(systemName: "trash.fill")
                           .font(.title3)
                           .symbolRenderingMode(.hierarchical)
                           .foregroundStyle(theme.primary)
                       .opacity(!selectedCustomMissions.isEmpty ? 1 : 0.3)
                           .symbolEffect(.bounce, value: selectedFilter == .custom) // fun pop on appear
                   }
                   .disabled(selectedCustomMissions.isEmpty)
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
            
            // MARK: List of missions
            ScrollView {
                VStack(spacing: 16) {
                    if !filteredMissions.isEmpty {
                        ForEach(filteredMissions, id: \.id) { mission in
                            MissionRow(mission: mission).tapBounce()
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
        .alert("Delete Selected Missions?",
               isPresented: $showDeleteConfirmation) {
            Button("Cancel", role: .cancel) {}
            Button("Delete", role: .destructive) {
                missionController.deleteMissions(selectedCustomMissions)
            }
        } message: {
            Text("You are about to delete \(selectedCustomMissions.count) mission(s). This action cannot be undone.")
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
    .modelContainer(SampleData.shared.modelContainer)
    .environment(\.theme, .orange)
}
