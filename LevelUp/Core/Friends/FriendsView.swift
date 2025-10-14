//
//  Friends.swift
//  LevelUp
//
//  Created by Raúl Pichardo Avalo on 9/8/25.
//

import SwiftUI
import SwiftData


// MARK: - Friends View
struct FriendsView: View {
    
    @Environment(\.theme) private var theme
    @State private var userQuery: String = ""
    @State private var showAddSheet = false
    @State private var showNotificationsSheet = false
    @State private var selectedFriend: Friend? = nil
    @State private var friendRequests: [FriendRequest] = []
    
    @Environment(\.modelContext) private var context
    @Environment(\.currentUser) private var user
    
    private var userController: UserController {
        UserController(context: context )
    }
    
    private func loadPendingRequests() async {
        do {
            print("Loading Pending request")
            friendRequests = try await userController.fetchPendingFriendRequests(for: user)
            print("Loaded requests: \(friendRequests.count)")
            
            for request in friendRequests {
                print("Sender \(request.from.friendId) | Receiver \(request.to)")
            }
        } catch {
            print("❌ Failed to fetch pending requests: \(error)")
            friendRequests = []
        }
    }

    var friends: [Friend]  {
        user.friends
    }
    
//    let pending: String = friendRequestStatus.pending.rawValue
//    @Query(filter: #Predicate<FriendRequest> {
//        $0.statusRaw == pending
//    },
//    sort: [SortDescriptor(\.createdAt, order: .reverse)]
//    )
//    private var allPendingRequests: [FriendRequest]
//
//    var pendingRequests: [FriendRequest] {
//        allPendingRequests.filter { $0.from.friendId == user.id }
//    }
    
    var hasFriends: Bool { !friends.isEmpty  || !friendRequests.isEmpty}
    
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
                
                if !hasFriends {
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
                        
                        // NEW SECTION ↓
                        if !friendRequests.isEmpty {
                            VStack(alignment: .leading, spacing: 10) {
                                Text("Pending Requests")
                                    .font(.headline.weight(.semibold))
                                    .foregroundStyle(theme.textPrimary)
                                    .padding(.horizontal, 20)
                                    .padding(.top, 16)

                                LazyVStack(spacing: 12) {
                                    ForEach(friendRequests) { request in
                                        FriendRow(friend: request.from, onPressLabel: "Pending")
                                            .disabled(true)
                                            .opacity(0.5)
                                            .padding(.horizontal, 20)
                                    }
                                }
                            }
                        }
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
            .onAppear {
                Task {
//                   try await userController.deleteAllFriendRequest(for: user)
                    await loadPendingRequests()
                }
            }
            
            .offset(y: -40)
        }
        .background(theme.background.ignoresSafeArea())
        
    }
}



#Preview {
    FriendsView()
        .modelContainer(SampleData.shared.modelContainer)
        .environment(\.currentUser, User.sampleUserWithLogs())
        .environment(\.theme, .orange)
}
