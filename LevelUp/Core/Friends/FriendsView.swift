//
//  Friends.swift
//  LevelUp
//
//  Created by Raúl Pichardo Avalo on 9/8/25.
//

import SwiftUI
import SwiftData

struct ConfirmationModalModel<DataType>: Identifiable, Equatable {
    let id = UUID()
    let title: String
    let message: String?
    let confirmButtonTitle: String
    let cancelButtonTitle: String
    let data: DataType
    let confirmAction: (DataType) async throws -> Void

    static func == (lhs: ConfirmationModalModel<DataType>, rhs: ConfirmationModalModel<DataType>) -> Bool {
        lhs.id == rhs.id
    }
}


// MARK: - Friends View
struct FriendsView: View {
    
    // MARK: Environment
    @Environment(\.theme) private var theme
    @Environment(\.modelContext) private var context
    @Environment(\.currentUser) private var user
    @Environment(BadgeManager.self) private var badgeManager: BadgeManager?
    
    
    // MARK: State
    @State private var userQuery: String = ""
    @State private var selectedFriend: Friend? = nil
    @State private var userController: UserController? = nil
    @State private var initialized = false
    
    @State private var showAddSheet = false
    @State private var showNotificationsSheet = false
    @State private var showConfirmationModal: Bool = false
    
    @State private var activeModal: ConfirmationModalModel<AnyHashable>? = nil
    
    // MARK: Queries
    @Query private var friendRequests: [FriendRequest]
    @Query private var userNotifications: [AppNotification]
    
    // MARK: Init — define static predicates (not dynamic environment-dependent)
    init(userId: UUID) {
        let pendingStatus = AppNotification.StatusNotification.pending.rawValue
        
        
        _friendRequests = Query(
            filter: #Predicate<FriendRequest> {
                $0.statusRaw == pendingStatus
                && $0.from.friendId == userId
            },
            sort: [SortDescriptor(\.createdAt, order: .reverse)]
        )
        
        // MARK: User notifications
        let pendingStatusNotification = AppNotification.StatusNotification.pending.rawValue
        _userNotifications = Query(
            filter: #Predicate<AppNotification> {
                $0.statusRaw == pendingStatusNotification
                && $0.receiverId == userId
            },
            sort: [SortDescriptor(\.createdAt, order: .reverse)]
        )
    }
    
    // MARK: Body
    var body: some View {
        
        ZStack {
            
            VStack(spacing: 16) {
                
                // MARK: BANNER
                AppTopBanner(
                    title: "Friends",
                    subtitle: "Find and add friends",
                    onNotificationTap: { showNotificationsSheet = true }
                )
                
                VStack {
        
                    // MARK: USER SEARCH QUERY
                    searchFieldWithIconEvent(userQuery: $userQuery, toggleSheet: $showAddSheet)
                    
                    // MARK: EMPTY VIEW
                    if !hasFriends {
                        EmptyFriendsView(onAddPressed: { showAddSheet.toggle() })
                    } else {
                        friendsScrollView
                    }
                    
                    Spacer(minLength: 0)
                }
                .frame(maxHeight: .infinity, alignment: .top)
                .sheet(isPresented: $showAddSheet) {
                    AddFriendsView().presentationDetents([.medium, .large])
                }
                .sheet(isPresented: $showNotificationsSheet) {
                    FriendsNotifications(notifications: userNotifications)
                        .presentationDetents([.large])
                }
                .sheet(item: $selectedFriend) { friend in
                    FriendPreviewCard(friend: friend)
                        .presentationDetents([.medium])
                }
                .onAppear(perform: setupView)
                .offset(y: -40)
            }
            .background(theme.background.ignoresSafeArea())
            
    
            // MARK: Confirmation Modal ASYNC
            if let modal = activeModal {
                    AsyncConfirmationModal(
                        isPresented: Binding(
                            get: { activeModal != nil },
                            set: { if !$0 { activeModal = nil } }
                        ),
                        title: modal.title,
                        message: modal.message,
                        confirmButtonTitle: modal.confirmButtonTitle,
                        cancelButtonTitle: modal.cancelButtonTitle,
                        confirmAction: { _ in
                            try await modal.confirmAction(modal.data)
                        },
                        data: modal.data
                    )
                    .environment(\.theme, theme)
                    .transition(.scale(scale: 0.9).combined(with: .opacity))
                    .zIndex(100)
                }
            }
            .animation(.spring(response: 0.45, dampingFraction: 0.8), value: activeModal)
    }
    
    // MARK: Subviews
    private var friendsScrollView: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(filteredFriends) { friend in
                    FriendRow(friend: friend, onPress: { f in
                        selectedFriend = f })
                    .onTapGesture {
                        selectedFriend = friend
                    }
                    .tapBounce()
                    .padding(.horizontal, 20)
                }
            
                if !friendRequests.isEmpty {
                    PendingFriendRequestView(
                        friendRequests: friendRequests,
                        onCancelRequest: { friendRequest in
                            activeModal = ConfirmationModalModel(
                                title: "Cancel Friend Request?",
                                message: "Are you sure you want to cancel your request to \(friendRequest.to.username)?",
                                confirmButtonTitle: "Yes, Cancel",
                                cancelButtonTitle: "No",
                                data: friendRequest,
                                confirmAction: { _ in
                                    try await userController?.cancelFriendRequest(friendRequest)
                                }
                            )
                        }
                    )
                }
            }
            .padding(.vertical, 9)
            .animation(.easeInOut(duration: 0.35), value: friendRequests.count)
        }
        .scrollIndicators(.hidden)
    }
    
    // MARK: Setup
    private func setupView() {
        guard !initialized else { return }
        initialized = true
        
        // Now environments exist → safe to build the controller
        userController = UserController(context: context, user: user, badgeManager: badgeManager)
        
        Task {
            await loadFriendsNotifications()
            
            //            try await userController?.deleteAllFriendRequest()
            //            try await userController?.deleteAllNotifications()
            
            try? await Task.sleep(nanoseconds: 200_000_000)
            print("=============")
            print("Friend Requests: \(friendRequests.count)")
            print("Notifications: \(userNotifications.count)")
            print("=============")
        }
    }
    
    // MARK: Logic
    private func loadFriendsNotifications() async {
        guard let userController else { return }
        do {
            try await userController.loadNotifications()
        } catch {
            print("❌ Failed to load friend notifications: \(error)")
        }
    }
    
    // MARK: Helpers
    private var hasFriends: Bool {
        !user.friends.isEmpty || !friendRequests.isEmpty
    }
    
    private var filteredFriends: [Friend] {
        let q = userQuery.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !q.isEmpty else { return user.friends }
        return user.friends.filter {
            String($0.stats.level).localizedCaseInsensitiveContains(q)
            || $0.username.localizedCaseInsensitiveContains(q)
        }
    }
}

// MARK: - Preview
#Preview {
    FriendsView(userId: UUID(uuidString: "11111111-1111-1111-1111-111111111111")!)
        .modelContainer(SampleData.shared.modelContainer)
        .environment(\.currentUser, User.sampleUserWithLogs())
        .environment(\.theme, .orange)
        .environment(BadgeManager()) // 👈 inject preview manager
}
