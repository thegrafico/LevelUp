//
//  Friends.swift
//  LevelUp
//
//  Created by Raúl Pichardo Avalo on 9/8/25.
//

import SwiftUI

// MARK: - UI Model (demo)
struct UIFriend: Identifiable {
    let id = UUID()
    var name: String
    var username: String
    var avatar: String   // SF Symbol
    var isOnline: Bool
}



private let demoFriends: [UIFriend] = [
    .init(name: "Ava",    username: "@ava",    avatar: "person.circle.fill", isOnline: true),
    .init(name: "Liam",   username: "@liam",   avatar: "person.crop.circle.fill", isOnline: false),
    .init(name: "Maya",   username: "@maya",   avatar: "person.fill", isOnline: true),
    .init(name: "Noah",   username: "@noah",   avatar: "person.fill", isOnline: false),
    .init(name: "Sofia",  username: "@sofia",  avatar: "person.fill", isOnline: true),
]

struct BannerHeader: View {
    @Environment(\.theme) private var theme
    var title: String
    var subtitle: String
    var onNotificationTap: (() -> Void)? = nil // 👈 callback
    
    var height: CGFloat = 200
    var radius: CGFloat = 0
    
    var body: some View {
        TopBannerBackground(height: height, radius: radius)
            .overlay(alignment: .bottomLeading) {
                HStack(alignment: .bottom) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(title)
                            .font(.system(size: 34, weight: .black, design: .rounded))
                            .kerning(1.5)
                            .foregroundStyle(theme.textInverse)
                        Text(subtitle)
                            .font(.headline)
                            .foregroundStyle(theme.textInverse.opacity(0.85))
                    }
                    
                    Spacer()
                    
                    Button {
                        UIImpactFeedbackGenerator(style: .soft).impactOccurred()
                        
                        onNotificationTap?()
                    } label: {
                        Image(systemName: "bell.badge.fill")
                            .font(.system(size: 22, weight: .semibold))
                            .foregroundStyle(theme.textInverse.opacity(0.9))
                            .padding(10)
                            .background(
                                Circle()
                                    .fill(theme.textInverse.opacity(0.1))
                            )
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 14)
            }
            .frame(height: height)
            .ignoresSafeArea(edges: .top)
    }
}

// MARK: - Friends View
struct FriendsView: View {
    @Environment(\.theme) private var theme
    @State private var query: String = ""
    @State private var showAddSheet = false
    @State private var showNotificationsSheet = false // 👈 new
    
    
    @State private var friends: [UIFriend] = demoFriends
    
    var filtered: [UIFriend] {
        let q = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !q.isEmpty else { return friends }
        return friends.filter { $0.name.localizedCaseInsensitiveContains(q) || $0.username.localizedCaseInsensitiveContains(q) }
    }
    
    var body: some View {
        VStack(spacing: 16) {
            // Banner header with title on top of gradient
            BannerHeader(
                title: "Friends",
                subtitle: "Find and add friends",
                onNotificationTap: { showNotificationsSheet = true }
            )
            
            VStack {
                
                // Search
                HStack(spacing: 8) {
                    Image(systemName: "magnifyingglass").foregroundStyle(theme.textSecondary)
                    TextField("Search friends", text: $query)
                        .textInputAutocapitalization(.never)
                        .disableAutocorrection(true)
                    
                    Button { showAddSheet = true } label: {
                        Label("Add", systemImage: "person.badge.plus")
                            .labelStyle(.iconOnly)
                            .font(.title3.weight(.semibold))
                            .foregroundStyle(theme.primary)
                            .padding(10)
                            .background(
                                RoundedRectangle(cornerRadius: theme.cornerRadiusSmall)
                                    .fill(theme.primary.opacity(0.12))
                            )
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .background(theme.cardBackground)
                .clipShape(RoundedRectangle(cornerRadius: theme.cornerRadiusLarge, style: .continuous))
                .shadow(color: theme.shadowLight, radius: 6, y: 3)
                .padding(.horizontal, 20)
                
                // Only the list scrolls
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(filtered) { f in
                            FriendRow(friend: f)
                                .padding(.horizontal, 20)
                        }
                    }
                    .padding(.vertical, 8)
                }
                .scrollIndicators(.hidden)
                
                Spacer(minLength: 0)
            }
            .frame(maxHeight: .infinity, alignment: .top)
            .sheet(isPresented: $showAddSheet) {
                AddFriendsSheet()
                    .presentationDetents([.height(360), .medium])
            }
            .sheet(isPresented: $showNotificationsSheet) {
                NotificationsSheet()
                    .presentationDetents([.large])
            }
            .offset(y: -40)
        }
        .background(theme.background.ignoresSafeArea())
        
    }
}

struct NotificationsSheet: View {
    @Environment(\.theme) private var theme
    @Environment(\.dismiss) private var dismiss
    
    @State private var expandedSections: Set<UserNotification.NotificationType> = [.friendRequest, .challenge]
    @State private var selectedFriend: UserNotification? = nil
    
    private let notifications: [UserNotification] = [
        .init(type: .friendRequest, senderName: "Ava", senderAvatar: "person.circle.fill", message: "sent you a friend request."),
        .init(type: .challenge, senderName: "Liam", senderAvatar: "flame.circle.fill", message: "challenged you to a 5K run!"),
        .init(type: .friendRequest, senderName: "Maya", senderAvatar: "person.fill", message: "wants to connect with you.")
    ]
    
    var groupedNotifications: [UserNotification.NotificationType: [UserNotification]] {
        Dictionary(grouping: notifications, by: { $0.type })
    }
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            VStack(spacing: 0) {
                // Custom top bar
                HStack {
                    Text("Notifications")
                        .font(.title3.bold())
                        .foregroundStyle(theme.textPrimary)
                    Spacer()
                    
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title2)
                            .foregroundStyle(theme.textSecondary.opacity(0.7))
                            .padding(16)
                    }
                    
                }
                .padding(.horizontal, 20)
                .padding(.top, 30)
                .padding(.bottom, 8)
                .background(theme.background.ignoresSafeArea())
                
                // Scrollable content
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {
                        ForEach(UserNotification.NotificationType.allCases, id: \.self) { type in
                            let items = groupedNotifications[type] ?? []
                            if !items.isEmpty {
                                NotificationSection(
                                    title: type.rawValue,
                                    notifications: items,
                                    isExpanded: expandedSections.contains(type),
                                    onToggle: {
                                        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                            if expandedSections.contains(type) {
                                                expandedSections.remove(type)
                                            } else {
                                                expandedSections.insert(type)
                                            }
                                        }
                                    },
                                    onViewTap: { notification in
                                        selectedFriend = notification
                                    }
                                )
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 20)
                }
                .background(theme.background.ignoresSafeArea())
            }
        }
        .sheet(item: $selectedFriend) {
            FriendPreviewCard(notification: $0)
                .presentationDetents([.medium])
        }
        .interactiveDismissDisabled(true)
        .presentationDetents([.fraction(1.0)])  // full height
        .presentationDragIndicator(.hidden)
    }
}

struct FriendPreviewCard: View {
    @Environment(\.theme) private var theme
    var notification: UserNotification
    
    var body: some View {
        VStack(spacing: 16) {
            Circle()
                .fill(theme.primary.opacity(0.15))
                .frame(width: 100, height: 100)
                .overlay(
                    Image(systemName: notification.senderAvatar)
                        .font(.system(size: 50, weight: .bold))
                        .foregroundStyle(theme.primary)
                )
            
            Text(notification.senderName)
                .font(.title2.weight(.bold))
                .foregroundStyle(theme.textPrimary)
            
            Text("Level 7 • Best Streak: 12 days")
                .font(.subheadline)
                .foregroundStyle(theme.textSecondary)
            
            Divider().padding(.vertical, 8)
            
            VStack(spacing: 10) {
                statRow(icon: "flame.fill", title: "Challenges Won", value: "5")
                statRow(icon: "bolt.fill", title: "Top Mission", value: "Morning Run")
                statRow(icon: "clock.fill", title: "Last Active", value: "2 hours ago")
            }
            
            Spacer()
            
            Button {
                // accept or view full profile later
            } label: {
                Text("Send Request Back")
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(theme.textInverse)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(RoundedRectangle(cornerRadius: theme.cornerRadiusLarge).fill(theme.primary))
            }
        }
        .padding(20)
        .background(theme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: theme.cornerRadiusLarge))
        .shadow(color: theme.shadowLight, radius: 10, y: 4)
        .presentationBackground(theme.background)
    }
    
    @ViewBuilder
    private func statRow(icon: String, title: String, value: String) -> some View {
        HStack {
            Image(systemName: icon)
                .foregroundStyle(theme.primary)
            Text(title)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(theme.textPrimary)
            Spacer()
            Text(value)
                .font(.subheadline)
                .foregroundStyle(theme.textSecondary)
        }
    }
}

struct NotificationRow: View {
    @Environment(\.theme) private var theme
    var notification: UserNotification
    var onViewTap: (UserNotification) -> Void
    
    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(theme.primary.opacity(0.15))
                    .frame(width: 48, height: 48)
                Image(systemName: notification.senderAvatar)
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundStyle(theme.primary)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(notification.senderName)
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(theme.textPrimary)
                Text(notification.message)
                    .font(.subheadline)
                    .foregroundStyle(theme.textSecondary)
            }
            
            Spacer()
            
            Button {
                onViewTap(notification)
            } label: {
                Text("View")
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(theme.textInverse)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(
                        Capsule().fill(theme.primary)
                    )
            }
            .buttonStyle(.plain)
        }
        .padding(10)
        .background(theme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: theme.cornerRadiusMedium))
        .shadow(color: theme.shadowLight.opacity(0.4), radius: 4, y: 2)
    }
}

struct NotificationSection: View {
    @Environment(\.theme) private var theme
    var title: String
    var notifications: [UserNotification]
    var isExpanded: Bool
    var onToggle: () -> Void
    var onViewTap: (UserNotification) -> Void
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Text(title)
                    .font(.headline.weight(.bold))
                    .foregroundStyle(theme.textPrimary)
                Spacer()
                Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                    .foregroundStyle(theme.textSecondary)
                    .font(.subheadline)
            }
            .padding(.horizontal, 8)
            .contentShape(Rectangle())
            .onTapGesture(perform: onToggle)
            .padding(.bottom, 4)
            
            if isExpanded {
                VStack(spacing: 12) {
                    ForEach(notifications) { note in
                        NotificationRow(notification: note, onViewTap: onViewTap)
                    }
                }
                .transition(.opacity.combined(with: .slide))
            }
        }
        .padding()
        .background(theme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: theme.cornerRadiusLarge))
        .shadow(color: theme.shadowLight, radius: 8, y: 4)
        .animation(.spring(response: 0.4, dampingFraction: 0.7), value: isExpanded)
    }
}

struct UserNotification: Identifiable {
    enum NotificationType: String, CaseIterable {
        case friendRequest = "Friend Requests"
        case challenge = "Challenges"
    }
    
    var id = UUID()
    var type: NotificationType
    var senderName: String
    var senderAvatar: String
    var message: String
    var date: Date = Date()
    
    // Example future fields: missionName, streakCount, etc.
}

// MARK: - Friend Row
struct FriendRow: View {
    @Environment(\.theme) private var theme
    var friend: UIFriend
    
    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: theme.cornerRadiusSmall, style: .continuous)
                    .fill(friend.isOnline ? theme.primary.opacity(0.18) : theme.textPrimary.opacity(0.08))
                    .frame(width: 48, height: 48)
                Image(systemName: friend.avatar)
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundStyle(friend.isOnline ? theme.primary : theme.textSecondary)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 6) {
                    Text(friend.name)
                        .font(.headline.weight(.semibold))
                        .foregroundStyle(theme.textPrimary)
                    if friend.isOnline {
                        Circle().fill(theme.primary).frame(width: 6, height: 6)
                    }
                }
                Text(friend.username)
                    .font(.subheadline)
                    .foregroundStyle(theme.textSecondary)
            }
            Spacer()
            
            // Placeholder action (e.g., view profile / challenge)
            Button {
                // wire later
            } label: {
                Text("Challenge")
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(theme.primary)
                    .padding(.horizontal, 10).padding(.vertical, 8)
                    .background(Capsule().fill(theme.primary.opacity(0.1)))
            }
            .buttonStyle(.plain)
        }
        .padding(12)
        .background(theme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: theme.cornerRadiusLarge, style: .continuous))
        .shadow(color: theme.shadowLight, radius: 6, y: 3)
    }
}

// MARK: - Add Friends Sheet
struct AddFriendsSheet: View {
    @Environment(\.theme) private var theme
    @State private var inviteCode: String = ""
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                // Connect Facebook (placeholder)
                Button {
                    // TODO: integrate FB SDK or Contacts
                } label: {
                    HStack(spacing: 12) {
                        ZStack {
                            RoundedRectangle(cornerRadius: theme.cornerRadiusSmall)
                                .fill(theme.primary.opacity(0.12))
                                .frame(width: 40, height: 40)
                            Image(systemName: "f.cursive.circle.fill")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundStyle(theme.primary)
                        }
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Connect Facebook")
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(theme.textPrimary)
                            Text("Find friends from your contacts")
                                .font(.footnote)
                                .foregroundStyle(theme.textSecondary)
                        }
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundStyle(theme.textSecondary)
                    }
                    .padding(14)
                    .background(theme.cardBackground)
                    .clipShape(RoundedRectangle(cornerRadius: theme.cornerRadiusLarge))
                    .shadow(color: theme.shadowLight, radius: 6, y: 3)
                }
                .buttonStyle(.plain)
                .padding(.horizontal, 16)
                
                // Or add by code
                VStack(alignment: .leading, spacing: 10) {
                    Text("Add by Code")
                        .font(.headline.weight(.semibold))
                        .foregroundStyle(theme.textPrimary)
                    
                    HStack(spacing: 10) {
                        TextField("Enter code (e.g., 7F4Q-92K)", text: $inviteCode)
                            .textInputAutocapitalization(.never)
                            .disableAutocorrection(true)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 10)
                            .background(theme.cardBackground)
                            .clipShape(RoundedRectangle(cornerRadius: theme.cornerRadiusSmall))
                            .overlay(
                                RoundedRectangle(cornerRadius: theme.cornerRadiusSmall)
                                    .stroke(theme.textPrimary.opacity(0.08), lineWidth: 1)
                            )
                        
                        Button {
                            // TODO: validate & add friend
                        } label: {
                            Text("Add")
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(theme.textInverse)
                                .padding(.horizontal, 14)
                                .padding(.vertical, 10)
                                .background(
                                    RoundedRectangle(cornerRadius: theme.cornerRadiusSmall)
                                        .fill(theme.primary)
                                )
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(16)
                .background(theme.cardBackground)
                .clipShape(RoundedRectangle(cornerRadius: theme.cornerRadiusLarge))
                .shadow(color: theme.shadowLight, radius: 6, y: 3)
                .padding(.horizontal, 16)
                
                Spacer()
            }
            .padding(.top, 12)
            .background(theme.background.ignoresSafeArea())
            .navigationTitle("Add Friends")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    FriendsView()
        .environment(\.theme, .orange)
}
