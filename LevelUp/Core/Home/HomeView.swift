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
        MissionController(context: context, user: user, badgeManager: badgeManager)
    }
    
    // MARK: All Missions
    private var allMissions: [Mission] {
        user.allMissions
    }
    
    var body: some View {
        VStack(spacing: 0) {
            
            // MARK: HEADER
            Header()
            
            
            // MARK: Quick actions and Today's progress
            MiddleHubSection()
                .padding(.bottom, 12)
            
            // MARK: Mission List
            MissionList(user.customMissions, user.globalMissions)

        }
        .background(Color(.systemGroupedBackground))
        .safeAreaInset(edge: .bottom) {
            VStack(spacing: 12) {
                // MARK: Complete BTN
                let selectedMissions = allMissions.filter(\.isSelected)
                if !selectedMissions.isEmpty {
                    CompleteButton(title: "Complete \(selectedMissions.count)x") {
                        missionController.markAsCompleted(selectedMissions)
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
