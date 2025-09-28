import SwiftUI
import SwiftData

struct HomeView: View {
    
    // MARK: Getting User Custom Missions
    @Query private var customMissions: [Mission]
    @Query private var globalMissions: [Mission]
    @State private var animateBounce = false
    
    @Environment(\.currentUser) private var user
    @Environment(\.modelContext) private var context
    @Environment(BadgeManager.self) private var badgeManager: BadgeManager?

    private var missionController: MissionController {
        MissionController(context: context, badgeManager: badgeManager)
    }
    
    // MARK: All Missions
    private var allMissions: [Mission] {
        globalMissions + customMissions
    }
    
    init() {
        // Hacky way of using Query with enums. They need to be declared firts.
        let customMissionType = MissionType.custom.rawValue
        let globalMissionType = MissionType.global.rawValue
        
        _customMissions = Query(filter: #Predicate<Mission> { $0.typeRaw == customMissionType})
        
        _globalMissions = Query(filter: #Predicate<Mission> { $0.typeRaw == globalMissionType})
    }
    
    
    var body: some View {
        VStack(spacing: 0) {
            
            // MARK: HEADER
            Header()
            
            
            // MARK: Quick actions and Today's progress
            MiddleHubSection()
                .padding(.bottom, 12)
            
            // MARK: Mission List
            MissionList(customMissions, globalMissions)

        }
        .background(Color(.systemGroupedBackground))
        .safeAreaInset(edge: .bottom) {
            VStack(spacing: 12) {
                // MARK: Complete BTN
                let selectedMissions = allMissions.filter(\.isSelected)
                if !selectedMissions.isEmpty {
                    CompleteButton(title: "Complete \(selectedMissions.count)x") {
                        missionController.markAsCompleted(selectedMissions, forUser: user)
                    }
                    .scaleEffect(animateBounce ? 1.1 : 0.9)
                    .padding(.bottom, 20)
                    .onChange(of: selectedMissions.count) {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            animateBounce = true
                        }
                        // Reset back to normal after delay
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                            withAnimation(.spring()) {
                                animateBounce = false
                            }
                        }
                    }
                }
            }
        }
    }
}



#Preview {
    HomeView()
        .modelContainer(SampleData.shared.modelContainer)
        .environment(\.theme, .orange)
        .environment(BadgeManager())
        .environment(\.currentUser, User.sampleUser())

    
}
