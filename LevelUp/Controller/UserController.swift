//
//  UserController.swift
//  LevelUp
//
//  Created by Raúl Pichardo Avalo on 10/9/25.
//

import Foundation
import SwiftData
import SwiftUI

@MainActor
final class UserController {
    let context: ModelContext
    private let badgeManager: BadgeManager?
    let user: User?
    
    init(context: ModelContext, user: User? = nil, badgeManager: BadgeManager? = nil) {
        self.context = context
        self.user = user
        self.badgeManager = badgeManager
    }
}

// MARK: AUTH
extension UserController {
    /// Creates a new user in SwiftData.
    /// - Throws: `UserError` if email is taken or invalid data.
    func createUser(username: String, email: String, password: String) throws -> User {
        // Check if user already exists by email
        let descriptor = FetchDescriptor<User>(
            predicate: #Predicate { $0.email == email || $0.username == username}
        )
        let existing = try context.fetch(descriptor)
        if !existing.isEmpty {
            throw UserError.usernameOrEmailTaken
        }
        
        // Hash the password (you can replace with proper cryptographic hash later)
        let passwordHash = hash(password)
        
        let user = User(
            username: username,
            passwordHash: passwordHash,
            email: email,
        )
        
        context.insert(user)
        try context.save()
        
        print("✅ User \(username) created and saved to SwiftData.")
        return user
    }
    
    func authenticate(identifier: String, password: String) async throws -> User {
        let allUsers = try context.fetch(FetchDescriptor<User>())
        
        guard let user = allUsers.first(where: {
            $0.email.lowercased() == identifier.lowercased() ||
            $0.username.lowercased() == identifier.lowercased()
        }) else {
            throw AuthError.userNotFound
        }
        
        guard user.passwordHash == hash(password) else {
            throw AuthError.invalidPassword
        }
        
        return user
    }
    
    func searchUsers(byUsername query: String, ignoredIDs: [UUID] = []) async throws -> [User] {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return [] }
        
        let descriptor = FetchDescriptor<User>(
            predicate: #Predicate { user in
                user.username.localizedStandardContains(trimmed)
                && !ignoredIDs.contains(user.id)
                
            },
            sortBy: [SortDescriptor(\.username)]
        )
        
        return try context.fetch(descriptor)
    }
    
    /// Fake hash for now — replace with CryptoKit later.
    private func hash(_ string: String) -> String {
        return String(string.reversed()) + "_hash"
    }
}

// MARK: ENUMS
extension UserController {
    enum AuthError: LocalizedError {
        case userNotFound
        case invalidPassword
        
        var errorDescription: String? {
            switch self {
            case .userNotFound: return "No account found for that username or email."
            case .invalidPassword: return "Incorrect password. Try again."
            }
        }
    }
    
    enum UserError: LocalizedError {
        
        // MARK: - General / User-related
        case usernameOrEmailTaken
        case usernameTaken
        case emailTaken
        case invalidInput
        case authenticationFailed(message: String)
        case invalidUser(message: String = "Invalid user.")

        // MARK: - Friend Request
        case friendAlreadySent
        case friendInvalidTarget
        case friendGeneral(message: String = "Something went wrong. Try again later.")

        // MARK: - Computed descriptions
        var errorDescription: String? {
            switch self {
            // MARK: General / User errors
            case .emailTaken:
                return "This email is already registered."
            case .invalidInput:
                return "Invalid user information."
            case .usernameOrEmailTaken:
                return "This username or email is already registered."
            case .usernameTaken:
                return "This username is already registered."
            case .authenticationFailed(let message):
                return message
            case .invalidUser(let message):
                return message

            // MARK: Friend request errors
            case .friendAlreadySent:
                return "You’ve already sent this friend request."
            case .friendInvalidTarget:
                return "This user cannot receive friend requests."
            case .friendGeneral(let message):
                return message
            }
        }
    }

    
}


// MARK: FRIEND REQUEST
extension UserController {
    
    func fetchPendingFriendRequests(for user: User) async throws -> [FriendRequest] {
        print("Fetching friend request sent by me...")
        let pendingStatus: String = AppNotification.StatusNotification.pending.rawValue
        let userId: UUID = user.id
        print("User: \(user.username), id: \(userId)")
        let descriptor = FetchDescriptor<FriendRequest>(
            predicate: #Predicate { request in
                request.statusRaw == pendingStatus
                && request.from.friendId == userId
            },
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        )
        
        return try context.fetch(descriptor)
    }
    
    func sendFriendRequest(from sender: User, to friend: Friend) async throws -> Void {
        print("Sending request...")
        
        // TODO: remove on production. just for testing purpouse
        try await Task.sleep(nanoseconds: 1_000_000_000) // 2s
        
        let friendId = friend.friendId
        let senderId = sender.id
        
        let queryToGetFriendRequestBySender = FetchDescriptor<FriendRequest>(
            predicate: #Predicate { $0.from.friendId == senderId && $0.to.friendId == friendId}
        )
        
        let existingFriendRequest = try context.fetch(queryToGetFriendRequestBySender)
        
        if !existingFriendRequest.isEmpty {
            throw UserError.friendAlreadySent
        }
        
        let request = FriendRequest(
            from: sender.asFriend(),
            to: friend,
            status: .pending
        )
        do {
            context.insert(request)
            try context.save()
            print("Friend Request sent sucessfully!: From: \(request.from.friendId) to: \(request.to)")
        }catch {
            print("There was an error: \(error)")
            throw UserError.friendGeneral(message: "There was an error sending the friend request")
        }
        
    }
    
    func deleteAllFriendRequest() async throws -> Void {
        guard user != nil else { return }
        
        try context.delete(model: FriendRequest.self, where: #Predicate<FriendRequest> { _ in true })
        
        try context.save()
    }
    
    func cancelFriendRequest(_ friendRequest: FriendRequest) async throws -> Void {
        guard let userId = user?.id else {
            print("Invalid user for cancelling friend request")
            throw UserError.invalidUser(message: "Invalid user. Log in again")
        }
        
        if friendRequest.from.friendId != userId {
            print("This is not your friend request to cancel")
            throw UserError.authenticationFailed(message: "You cannot cancel another user's friend request.")
        }
        
        // Notifications stores friend request by saving the id into a PayloadId
        let payloadId = friendRequest.id
        
        // MARK: cancel notifications
        try? await updateNotificationStatus(payloadId: payloadId, to: .canceled)
        
        // MARK: Update friend request status
        friendRequest.updateStatus(to: .canceled)
        
        try context.save()
        
    }
    
    private func updateNotificationStatus(payloadId: UUID, to newStatus: AppNotification.StatusNotification) async throws {
        // 1️⃣ Query all notifications matching the payloadId
        let descriptor = FetchDescriptor<AppNotification>(
            predicate: #Predicate { $0.payloadId == payloadId }
        )

        let notifications = try context.fetch(descriptor)

        guard !notifications.isEmpty else {
            print("No notification found for this request.")
            return
        }

        // 2️⃣ Update all matching notifications
        for notification in notifications {
            notification.updateStatus(to: newStatus)
        }

        // 3️⃣ Save the context
        try context.save()

        print("✅ Updated \(notifications.count) notification(s) to status '\(newStatus.rawValue)' for payloadId: \(payloadId)")
    }
    
}

// MARK: NOTIFICATIONS
extension UserController {
    
    func deleteAllNotifications() async throws -> Void {
        guard user != nil else { return }
        
        try context.delete(model: AppNotification.self, where: #Predicate<AppNotification> { _ in true })
        try context.save()
    }
    
    func loadNotifications() async throws -> Void {
        
        guard user != nil else {
            print("Invalid user for loading notifications")
            return
        }
    
        print("Loading user notifications...")
        var newNotificationsCount: Int = 0
        
        // on memory notifications
        let existingNotifications = try await getNotifications()
        newNotificationsCount += existingNotifications.filter({!$0.isRead}).count
    
        // Possible New Notifications
        let friendRequestsAsNotifications = try await getFriendRequestAsNotifications()
        
        print("🆕 Incoming friend request notifications (\(friendRequestsAsNotifications.count)):")
           for note in friendRequestsAsNotifications {
               print("   - FriendRequest ID: \(note.payloadId?.uuidString ?? "nil")")
           }

        
        for friendNotification in friendRequestsAsNotifications {
            if !existingNotifications.contains(where: { $0.payloadId == friendNotification.payloadId }) {
                newNotificationsCount += 1
                print("Adding new friend Notifications for current user!")
                context.insert(friendNotification)
            }else {
                print("Notification already exists! \(String(describing: friendNotification.payloadId))")
            }
        }
        
        badgeManager?.set(.FriendsNotification, to: newNotificationsCount)

        // 5️⃣ Save context and return all notifications for the user
        try context.save()
        
        // MARK: TODO: FRIEND CHALLENGES
        // MARK: TODO: SYSTEM NOTIFICATIONS
        
        print("Notifications found: \(friendRequestsAsNotifications.count)")
        return
    }
    
    func getFriendRequestAsNotifications() async throws -> [AppNotification] {
        
        guard let userId = user?.id else {
            print("Invalid user for loading Friend Request")
            return []
        }
        
        print("Loading Friend Request as notifications...")

        let pendingStatus: String = AppNotification.StatusNotification.pending.rawValue
        
        let queryToGetMyFriendRequest = FetchDescriptor<FriendRequest> (
            predicate: #Predicate { friendRequest in
                friendRequest.to.friendId == userId && friendRequest.statusRaw == pendingStatus
            }
        )
        
        let friendRequest = try context.fetch(queryToGetMyFriendRequest)
        print("Found \(friendRequest.count) Friend Request for user ID: \(userId)")
        
        return friendRequest.asNotifications()
    }
    
    func getNotifications(withStatus: AppNotification.StatusNotification = .pending) async throws -> [AppNotification] {
        
        guard let userId = user?.id else {
            print("Invalid user for loading All notifications")
            return []
        }
        
        print()
        print("Getting All notifications...")
        
        // MARK: QUERY
        let notificationStatus: String = withStatus.rawValue
        let queryToGetexistingNotifications = FetchDescriptor<AppNotification>(
            predicate: #Predicate { notification in
                notification.receiverId == userId
                && notification.statusRaw == notificationStatus
            }
        )
        
        // MARK: FETCH
        let notifications = try context.fetch(queryToGetexistingNotifications)
        print("Found \(notifications.count) existing notifications for user ID: \(userId)")
        
//        for notification in notifications {
//            print("RECEIVER: \(String(describing: notification.receiverId))")
//            print("PAYLOAD: \(String(describing: notification.payloadId))")
//        }
        
        print()
        
        return notifications
    }
}
