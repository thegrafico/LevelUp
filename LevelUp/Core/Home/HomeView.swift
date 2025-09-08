import SwiftUI

struct HomeView: View {
    private let bannerH: CGFloat = 220
    private let bannerCorner: CGFloat = 60

    var body: some View {
        VStack(spacing: 0) {

            // MARK: HEADER
            Header()

            // MARK: Quick actions and Today's progress
            MiddleHubSection()
                
            // MARK: Mission List
            MissionList()

        }
        .background(Color(.systemGroupedBackground))
        .safeAreaInset(edge: .bottom) {
            VStack(spacing: 12) {
                
                // MARK: COMPLETE BTN
                CompleteButton()
                    .padding(.bottom, 20)
            }
        }
    }
}

#Preview {
    HomeView()
        .environment(\.theme, .orange)
}
