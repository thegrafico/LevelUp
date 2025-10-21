//
//  UserControllerNotification.swift
//  LevelUp
//
//  Created by Raúl Pichardo Avalo on 10/20/25.
//

import Foundation
import SwiftData

 // MARK: NOTIFICATION HELPERS
extension UserController {
    
    func acceptNotification(_ notification: AppNotification) async throws {
        guard let payloadId = notification.payloadId else {
            print("Notification does not have any payloadId")
            return
        }
        
        switch notification.kind {
            
        case .friendRequest:
            try await acceptFriendRequest(with: payloadId)
            notification.updateStatus(to: .accepted)
        case .challenge:
            print("Not supported now")
            break
        case .system:
            print("System notification cannot be declined.")
            break
        case .preview:
            print("Preview cannot be declined.")
            break
        }
    }
    
    func declineNotification(_ notification: AppNotification) async throws {
        
        guard let payloadId = notification.payloadId else {
            print("Notification doest not have any payloadId.")
            return
        }
        
        switch notification.kind {
                
            case .friendRequest:
              try await declineFriendRequest(with: payloadId)
            case .challenge:
                print("Not supported now")
                break
            case .system:
                print("System notification cannot be declined.")
                break
            case .preview:
                print("Preview cannot be declined.")
                break
        }
        
        notification.updateStatus(to: .declined)
        try context.save()
    }
    
    func updateNotificationStatus(payloadId: UUID, to newStatus: AppNotification.StatusNotification) async throws {
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
