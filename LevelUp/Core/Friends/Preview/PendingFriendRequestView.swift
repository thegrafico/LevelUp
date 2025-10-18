import SwiftUI

struct PendingFriendRequestView: View {
    @Environment(\.theme) private var theme

    var friendRequests: [FriendRequest]
    var onCancelRequest: ((FriendRequest) -> Void)?

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Pending Requests")
                .font(.headline.weight(.semibold))
                .foregroundStyle(theme.textPrimary)
                .padding(.horizontal, 20)
                .padding(.top, 16)

            LazyVStack(spacing: 12) {
                ForEach(friendRequests) { request in
                    FriendRow(friend: request.to, onPressLabel: "Cancel", onPress: { _ in
                        onCancelRequest?(request)
                    }, updateLabelOnComplete: false)
                    .opacity(0.6)
                    .padding(.horizontal, 20)
                }
            }
        }
    }
}

#Preview {
    PendingFriendRequestView(friendRequests: [SampleData.sampleFriendRequest1])
        .modelContainer(SampleData.shared.modelContainer)
        .environment(\.theme, .orange)
}
