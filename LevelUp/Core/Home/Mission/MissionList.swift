import SwiftUI
import SwiftData


// MARK: - Section
struct MissionList: View {
    @Environment(\.theme) private var theme
    @Environment(\.modelContext) private var context
    @Environment(BadgeManager.self) private var badgeManager: BadgeManager?
    @Environment(\.currentUser) private var user
    @EnvironmentObject private var modalManager: ModalManager
    
    @State private var selectedFilter: MissionType = .custom
    @State private var selectedSort: MissionSort = .name
    @State private var showDeleteConfirmation = false
    @State private var expandedCategories: Set<String> = ["General"]
    @State private var selectedMission: Mission? = nil
    
    private var missionController: MissionController {
        MissionController(context: context, user: user, badgeManager: badgeManager)
    }
    
    // MARK: Missions
    var customMissions: [Mission]
    var globalMissions: [Mission]
    var showAllSection: Bool = false
    
    init(_ customMissions: [Mission], _ globalMissions: [Mission]) {
        self.customMissions = customMissions
        self.globalMissions = globalMissions
        
        print("Custon Missions found: \(customMissions.count)")
        print("Global Missions found: \(globalMissions.count)")
    }
    
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
    
    private var groupedMissions: [(key: String, missions: [Mission])] {
        let grouped = Dictionary(grouping: filteredMissions, by: { $0.category.name })
        var result = grouped
            .map { (key: $0.key, missions: $0.value) }
            .sorted { $0.key.localizedCaseInsensitiveCompare($1.key) == .orderedAscending }
        
        // Add an “All” section at the top
        if !filteredMissions.isEmpty && showAllSection {
            result.insert((key: "All", missions: filteredMissions), at: 0)
        }
        
        return result
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
                        withAnimation(.spring(response: 0.45, dampingFraction: 0.8)) {
                            badgeManager?.clear(.filterMission(selectedFilter))
                        }
                    }
                
                Spacer()
                
                if selectedFilter == .custom {
                    MissionDeleteButton(
                        selectedMissions: selectedCustomMissions
                    ) {
                        missionController.deleteMissions(selectedCustomMissions)
                    }
                    .id("trash")
                }
                
                
                // MARK: SORT
                MissionSortMenu(selectedSort: $selectedSort)
                
                
            }.animation(
                .spring(
                    response: 0.35,
                    dampingFraction: 0.82),
                value: selectedFilter
            )
            .padding(.horizontal, 20)
            
            // MARK: List of missions
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(spacing: 0) {
                        // 👇 Static anchor stays even if the list updates
                        Color.clear
                            .frame(height: 0)
                            .id("TOP")
                        
                        LazyVStack(spacing: 12, pinnedViews: []) {
                            if !filteredMissions.isEmpty {
                                ForEach(groupedMissions, id: \.key) { category, missions in
                                    VStack(alignment: .leading, spacing: 8) {
                                        // MARK: Section Header
                                        Button {
                                            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                                if expandedCategories.contains(category) {
                                                    expandedCategories.remove(category)
                                                } else {
                                                    expandedCategories.insert(category)
                                                }
                                            }
                                        } label: {
                                            HStack {
                                                Text(category)
                                                    .font(.footnote.weight(.semibold))
                                                    .foregroundStyle(.secondary)
                                                    .padding(.top, 8)
                                                
                                                Spacer()
                                                
                                                if expandedCategories.contains(category) {
                                                    Image(systemName:"chevron.down")
                                                        .font(.subheadline)
                                                        .foregroundStyle(.secondary)
                                                } else {
                                                    Text("\(missions.count)")
                                                        .font(.subheadline)
                                                        .foregroundStyle(.secondary)
                                                }
                                            }
                                            .contentShape(Rectangle())
                                        }
                                        .buttonStyle(.plain)
                                        
                                        // MARK: Collapsible Content
                                        if expandedCategories.contains(category) {
                                            VStack(spacing: 12) {
                                                ForEach(missions, id: \.id) { mission in
                                                    MissionRow(mission: mission)
                                                        .onTapGesture { selectedMission = mission }
                                                        .tapBounce()
                                                        .id(mission.id)
                                                        .transition(.opacity.combined(with: .slide))
                                                }
                                            }
//                                            .padding(.horizontal, 12)
                                            .transition(.asymmetric(
                                                insertion: .opacity.combined(with: .move(edge: .top)),
                                                removal: .opacity.combined(with: .move(edge: .top))
                                            ))
                                        }
                                    }
                                    .padding(.bottom, 8)
                                }
                            } else {
                                ContentUnavailableView("No missions available", systemImage: "list.bullet.circle.fill")
                                    .fontWeight(.semibold)
                                    .opacity(0.5)
                                    .padding(.top, 30)
                                    .transition(.fadeRightToLeft)
                            }
                            
                            // ✅ Completed missions
                            if !completedMissions.isEmpty {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Completed today")
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
                                .transition(.move(edge: .bottom).combined(with: .opacity))
                            }
                        }
                        .padding(.top, 16)
                        .padding(.horizontal, 12)
                        .padding(.bottom, 20)
                    }
                }
                .padding(.horizontal, 6)
                .onChange(of: selectedFilter) {
                    
                    withAnimation(.spring(response: 0.6, dampingFraction: 0.85)) {
                        proxy.scrollTo("TOP", anchor: .top)
                    }
                    // Optional: collapse sections
                    expandedCategories.removeAll()
                }
            }
            .padding(.horizontal, 6)
        }.sheet(item: $selectedMission) { mission in
            MissionPreviewCard(mission: mission)
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
        .frame(maxWidth: .infinity, maxHeight: .infinity) // ✅ allow scroll & fill space
        .environmentObject(ModalManager()) // 👈 Inject for all child views
    
}
