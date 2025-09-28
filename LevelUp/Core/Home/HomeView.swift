import SwiftUI
import SwiftData

struct HomeView: View {
    
    // MARK: Getting User Custom Missions
    @Query private var customMissions: [Mission]
    @State private var globalMissions: [Mission] = Mission.sampleGlobalMissions
    
    // MARK: All Missions
    private var allMissions: [Mission] {
        globalMissions + customMissions
    }
    
    init() {
        // Hacky way of using Query with enums. They need to be declared firts.
        let customMissionType = MissionType.custom.rawValue
        
        _customMissions = Query(filter: #Predicate<Mission> { $0.typeRaw == customMissionType})
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
                if allMissions.contains(where: { $0.isSelected }) {
                    CompleteButton().padding(.bottom, 20)
                }
            }
        }
    }
}



#Preview {
    HomeView()
        .modelContainer(SampleData.shared.modelContainer)
        .environment(\.theme, .orange)
        .environmentObject(
            MissionController(context: SampleData.shared.modelContainer.mainContext))
        .environment(BadgeManager())

}
