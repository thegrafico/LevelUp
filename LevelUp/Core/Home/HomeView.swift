import SwiftUI

struct HomeView: View {
    private let bannerH: CGFloat = 220
    private let bannerCorner: CGFloat = 60

    var body: some View {
        VStack(spacing: 0) {

            // HEADER
            ZStack(alignment: .top) {
                TopBannerBackground(height: bannerH, radius: bannerCorner)
                    .ignoresSafeArea(edges: .top)

                VStack(spacing: 0) {
                    BannerTitle()
                    UserLevelXPCard()
                }
                .padding(.horizontal, 12)
            }

            // MARK: Quick actions and Today's progress
            MiddleHubSection()
                .padding(.horizontal, 20)
                .padding(.bottom, 12)
        
            // MARK: Mission List
            MissionList()

        }
        .background(Color(.systemGroupedBackground))
        .safeAreaInset(edge: .bottom) {
            VStack(spacing: 12) {
                CompleteButton()
                    .padding(.horizontal, 20)
                    .padding(.top, 12)
                    .padding(.bottom, 20)
            }
//            .background(Color(.systemGroupedBackground))
        }
    }
}

#Preview {
    HomeView()
}
