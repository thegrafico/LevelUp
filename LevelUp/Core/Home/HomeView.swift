import SwiftUI

struct HomeView: View {
    
    @State private var missions: [Mission] = Mission.sampleData


    var body: some View {
        VStack(spacing: 0) {

            // MARK: HEADER
            Header()

            // MARK: Quick actions and Today's progress
            MiddleHubSection()
                
            // MARK: Mission List
            MissionList(missions: $missions)

        }
        .background(Color(.systemGroupedBackground))
        .safeAreaInset(edge: .bottom) {
            VStack(spacing: 12) {
                
                if missions.contains(where: { $0.completed }) {
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
