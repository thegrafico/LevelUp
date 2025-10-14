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



private let demoFriends: [Friend] = [
    .init(username: "Alex", stats: .init(level: 20, topMission: "Drink Water", challengeWonCount: 10)),
    .init(username: "Raul", stats: .init(level: 25, topMission: "Golf", challengeWonCount: 10)),
    
]



// MARK: - Friends View
struct FriendsView: View {
    
    @Environment(\.theme) private var theme
    @State private var userQuery: String = ""
    @State private var showAddSheet = false
    @State private var showNotificationsSheet = false
    
    @State private var selectedFriend: Friend? = nil
    
    @State private var friends: [Friend] = demoFriends
    
    var filtered: [Friend] {
        let q = userQuery.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !q.isEmpty else { return friends }
        return friends.filter { String($0.stats.level).localizedCaseInsensitiveContains(q) || $0.username.localizedCaseInsensitiveContains(q) }
    }
    
    var body: some View {
        VStack(spacing: 16) {
            
            // Banner header with title on top of gradient
            AppTopBanner(
                title: "Friends",
                subtitle: "Find and add friends",
                onNotificationTap: { showNotificationsSheet = true }
            )
            
            VStack {
                
                // Search
                HStack(spacing: 8) {
                    Image(systemName: "magnifyingglass").foregroundStyle(theme.textSecondary)
                    TextField("Search friends", text: $userQuery)
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
                
                if friends.isEmpty {
                    EmptyFriendsView(onAddPressed: {
                        showAddSheet.toggle()
                    })
                } else {
                
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(filtered) { friend in
                                FriendRow(friend: friend, onPress: { friend in
                                    selectedFriend = friend
                                } )
                                .onTapGesture {
                                    selectedFriend = friend
                                }
                                    .tapBounce()
                                    
                                    .padding(.horizontal, 20)
                            }
                        }
                        .padding(.vertical, 8)
                    }
                    .scrollIndicators(.hidden)
                }
                
                Spacer(minLength: 0)
            }
            .frame(maxHeight: .infinity, alignment: .top)
            .sheet(isPresented: $showAddSheet) {
                AddFriendsView()
                    .presentationDetents([.medium, .large])
            }
            .sheet(isPresented: $showNotificationsSheet) {
                FriendsNotifications()
                    .presentationDetents([.large])
            }
            .sheet(item: $selectedFriend) { friend in
                FriendPreviewCard(friend: friend)
                    .presentationDetents([.medium])
            }
            
            .offset(y: -40)
        }
        .background(theme.background.ignoresSafeArea())
        
    }
}



#Preview {
    FriendsView()
        .environment(\.theme, .orange)
}
