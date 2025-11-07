import SwiftUI

struct FriendPreviewCardHeader: View {
    @Environment(\.theme) private var theme
    var friend: Friend

    init(_ friend: Friend) {
        self.friend = friend
    }

    var body: some View {
        HStack(alignment: .center, spacing: 14) {
            // 🧍 Avatar
            ZStack {
                Circle()
                    .fill(theme.primary.opacity(0.15))
                    .frame(width: 70, height: 70)
                Image(systemName: friend.avatar)
                    .font(.system(size: 38, weight: .bold))
                    .foregroundStyle(theme.primary)
            }

            // 🧩 Username + Level
            VStack(alignment: .leading, spacing: 4) {
                HStack(alignment: .top, spacing: 6) {
                    Text("@\(friend.username)")
                        .font(.title3.weight(.bold))
                        .foregroundStyle(theme.textPrimary)
                        .lineLimit(1)

                    // ⭐ Favorite toggle
                    Button {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                            friend.isFavorite.toggle()
                        }
                    } label: {
                        Image(systemName: friend.isFavorite ? "star.fill" : "star")
                            .symbolRenderingMode(.hierarchical)
                            .foregroundStyle(friend.isFavorite ? theme.primary : .secondary)
                            .font(.headline)
                            .padding(.trailing, 4)
                            .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(friend.isFavorite ? "Remove from favorites" : "Add to favorites")
                }

                // 🧠 Level + streak below
                HStack(spacing: 6) {
                    Text("Level \(friend.stats.level)")
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(theme.textSecondary)

                    if friend.stats.bestStreakCount > 0 {
                        Text("• Best Streak: \(friend.stats.bestStreakCount) days")
                            .font(.subheadline)
                            .foregroundStyle(theme.textSecondary)
                            .lineLimit(1)
                    }
                }
            }

            Spacer(minLength: 0)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 10)
    }
}

#Preview {
    FriendPreviewCardHeader(
        Friend(
            username: "thegrafico",
            stats: .init(level: 20, bestStreakCount: 10),
            avatar: "person.fill"
        )
    )
    .environment(\.theme, .orange)
}
