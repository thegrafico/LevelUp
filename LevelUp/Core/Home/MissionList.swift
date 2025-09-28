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
                            MissionRow(mission: mission)
                                .tapBounce()
                                .id(mission.id)
                                // MARK: Scale Transition
//                                .transition(.scale.combined(with: .opacity))
                                // MARK: Go left
//                                .transition(
//                                    .asymmetric(
//                                        insertion: .scale.combined(with: .opacity),
//                                        removal: .move(edge: .leading)
//                                            .combined(with: .opacity)
//                                            .combined(with: .scale(scale: 0.5))
//                                    )
//                                )
                            // MARK: Explosion
                                .transition(
                                    .asymmetric(
                                        insertion: .opacity,
                                        removal: .scale(scale: 1.3).combined(with: .opacity)
                                    )
                                )
                            // MARK: flip
//                                .transition(
//                                    .asymmetric(
//                                        insertion: .identity,
//                                        removal: .modifier(
//                                            active: FlipAwayModifier(),
//                                            identity: FlipAwayModifier(reset: true)
//                                        )
//                                    )
//                                )
                            // MARK: Blur
//                            .transition(
//                                .asymmetric(
//                                    insertion: .identity,
//                                    removal: .opacity
//                                        .combined(with: .scale(scale: 0.5))
//                                        .combined(with: .modifier(
//                                            active: BlurModifier(),
//                                            identity: BlurModifier(reset: true)
//                                        ))
//                                )
//                            )
                            
                            // MARK: DROP FADE
//                            .transition(
//                                .asymmetric(
//                                    insertion: .scale.combined(with: .opacity),
//                                    removal: .offset(y: 100)
//                                        .combined(with: .opacity)
//                                        .combined(with: .scale(scale: 0.8))
//                                )
//                            )
                            
                            // MARK: Sping
//                            .transition(
//                                .asymmetric(
//                                    insertion: .identity,
//                                    removal: .scale(scale: 0.5)
//                                        .combined(with: .opacity)
//                                        .combined(with: .modifier(
//                                            active: SpinModifier(),
//                                            identity: SpinModifier(reset: true)
//                                        ))
//                                )
//                            )
//                                .transition(.fadeRightToLeft)

                        }
                        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: customMissions)
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

extension AnyTransition {
    static var fadeRightToLeft: AnyTransition {
        .asymmetric(
            insertion: .opacity
                .combined(with: .move(edge: .trailing)),
            removal: .opacity
                .combined(with: .move(edge: .leading))
        )
    }
}

struct FlipAwayModifier: ViewModifier {
    var reset = false
    func body(content: Content) -> some View {
        content
            .rotation3DEffect(
                .degrees(reset ? 0 : 90),
                axis: (x: 0, y: 1, z: 0)
            )
            .opacity(reset ? 1 : 0)
    }
}

struct PixelateModifier: ViewModifier {
    var reset = false
    func body(content: Content) -> some View {
        content
            .blur(radius: reset ? 0 : 10)
            .saturation(reset ? 1 : 0.1)
    }
}

struct BlurModifier: ViewModifier {
    var reset = false
    func body(content: Content) -> some View {
        content.blur(radius: reset ? 0 : 8)
    }
}

struct SpinModifier: ViewModifier {
    var reset = false
    func body(content: Content) -> some View {
        content.rotationEffect(.degrees(reset ? 0 : 720))
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
