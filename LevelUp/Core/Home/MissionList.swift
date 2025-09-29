import SwiftUI
import SwiftData


// MARK: - Section
struct MissionList: View {
    @Environment(\.theme) private var theme
    @Environment(\.modelContext) private var context
    @Environment(BadgeManager.self) private var badgeManager: BadgeManager?

    private var missionController: MissionController {
        MissionController(context: context, badgeManager: badgeManager)
    }
    
    // MARK: Missions
    var customMissions: [Mission]
    var globalMissions: [Mission]
    
    init(_ customMissions: [Mission], _ globalMissions: [Mission]) {
        self.customMissions = customMissions
        self.globalMissions = globalMissions
    }
    
    // MARK: Filters
    @State private var selectedFilter: MissionType = .custom
    @State private var selectedSort: MissionSort = .name
    @State private var showDeleteConfirmation = false
        
    // MARK: Active missions (filtered + sorted)
    private var filteredMissions: [Mission] {
        let base: [Mission]

        switch selectedFilter {
            case .all: base = globalMissions + customMissions
            case .global: base = globalMissions
            case .custom: base = customMissions
        }
        
        // Keep only *active* ones here
        let activeBase = base.filter { !$0.isDisabledToday }
        
        // Apply sorting
        switch selectedSort {
            case .name:
                return activeBase.sorted { $0.title < $1.title }
            case .xpAscending:
                return activeBase.sorted { $0.xp < $1.xp }
            case .xpDescending:
                return activeBase.sorted { $0.xp > $1.xp }
            case .completed:
                return activeBase // all inactive, so "completed" sort doesn’t matter
            case .creationDateAscending:
                return activeBase.sorted { $0.createdAt > $1.createdAt }
            case .creationDateDescending:
                return activeBase.sorted { $0.createdAt < $1.createdAt }
        }
    }

    // MARK: Completed missions
    private var completedMissions: [Mission] {
        let base: [Mission]

        switch selectedFilter {
            case .all: base = globalMissions + customMissions
            case .global: base = globalMissions
            case .custom: base = customMissions
        }
        
        return base.filter { $0.isDisabledToday }
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
                    .onChange(of: selectedFilter) {
                        badgeManager?.clear(.filter(selectedFilter))
                        
                        print("Filtered missions: \(filteredMissions.count)")
                        missionController.printMissions(filteredMissions)
                        
                        print("customMissions: \(customMissions.count)")
                        print("global missions: \(globalMissions.count)")
                        
                        // MARK: TODO: Check this probably once at day
                        missionController.updateCompleteStatus(for: filteredMissions)
                    }
                
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
            // MARK: List of missions
            ScrollView {
                VStack(spacing: 16) {
                    // ✅ Active missions
                    if !filteredMissions.isEmpty {
                        ForEach(filteredMissions, id: \.id) { mission in
                            MissionRow(mission: mission)
                                .tapBounce()
                                .id(mission.id)
                                .transition(.fadeRightToLeft)
                        }
                        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: filteredMissions)
                    } else {
                        
                        if selectedFilter == .custom {
                            ContentUnavailableView("Add Mission", systemImage: "list.bullet.circle.fill")
                                .fontWeight(.semibold)
                                .opacity(0.5)
                                .padding(.top, 30)
                        } else {
                            EmptyView()
                        }
                        
                    }

                    // ✅ Completed missions section (only if non-empty)
                    if !completedMissions.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Completed")
                                .font(.footnote.weight(.semibold))
                                .foregroundStyle(.secondary)
                                .padding(.top, 8)

                            ForEach(completedMissions, id: \.id) { mission in
                                MissionRow(mission: mission)
                                    .grayscale(1.0)
                                    .opacity(0.5)
                                    .allowsHitTesting(false)
                                    .id(mission.id)
                                    .transition(.opacity.combined(with: .scale))
                            }
                        }
                        .padding(.top, 12)
                        .transition(.move(edge: .bottom).combined(with: .opacity)) // 👈 section slides in
                    }
                    
                }.animation(.spring(response: 0.6, dampingFraction: 0.8), value: completedMissions)
                .padding(.top, 16)
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
        }
        .alert("Delete Selected Missions?",
               isPresented: $showDeleteConfirmation) {
            Button("Cancel", role: .cancel) {}
            Button("Delete", role: .destructive) {
                print("Deleting missions...")
                withAnimation {
                    missionController.deleteMissions(selectedCustomMissions)
                }
            }
        } message: {
            Text("You are about to delete \(selectedCustomMissions.count) mission(s). This action cannot be undone.")
        }
    }
}

struct MissionListPreviewWrapper: View {
    
    
    @Query(filter: #Predicate<Mission> { $0.typeRaw == "Custom" })
    private var customMissions: [Mission]

//    @Query(filter: #Predicate<Mission> { $0.typeRaw == MissionType.global.rawValue })
    private var globalMissions: [Mission] = Mission.sampleGlobalMissions

    var body: some View {
        MissionList(customMissions, globalMissions)
    }
}


#Preview {
    MissionListPreviewWrapper()
        .modelContainer(SampleData.shared.modelContainer)
        .environment(BadgeManager())
}

//
//#Preview {
//    let context = SampleData.shared.modelContainer.mainContext
//    // Fetch missions manually
//    let fetchDescriptor = FetchDescriptor<Mission>()
//    let missions = try? context.fetch(fetchDescriptor)
//    
//    return MissionList(
//        missions?.filter { $0.type == .custom } ?? [],
//        missions?.filter { $0.type == .global } ?? []
//    )
//    .modelContainer(SampleData.shared.modelContainer)
//
//}
