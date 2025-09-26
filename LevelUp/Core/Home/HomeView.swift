import SwiftUI



struct HomeView: View {
    
    @State private var customMissions: [Mission] = Mission.sampleData
    @State private var globalMissions: [Mission] = Mission.sampleGlobalMissions
    @State private var user: User = User.sampleUser()
    
    private var allMissions: [Mission] {
        globalMissions + customMissions
    }
    
    
    var body: some View {
        VStack(spacing: 0) {

            // MARK: HEADER
            Header()

            // MARK: Quick actions and Today's progress
            MiddleHubSection()
                .padding(.bottom, 12)
                
            // MARK: Mission List
            MissionList(customMissions: $customMissions, globalMissions: $globalMissions)

        }
        .background(Color(.systemGroupedBackground))
        .safeAreaInset(edge: .bottom) {
            VStack(spacing: 12) {
                
                // MARK: Complete BTN
                if allMissions.contains(where: { $0.completed }) {
                    CompleteButton().padding(.bottom, 20)
                }
            }
        }
    }
}

#Preview {
    HomeView()
        .environment(\.theme, .orange)
}
