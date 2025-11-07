//
//  UserControllerFriendRequest.swift
//  LevelUp
//
//  Created by Raúl Pichardo Avalo on 10/20/25.
//

import Foundation
import SwiftData

// MARK: FRIEND REQUEST HELPERS
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
        try await Task.sleep(nanoseconds: 600_000_000)

        if sender.hasFriend(withId: friend.friendId) {
            print("Already part of your friends.")
            throw UserError.friendGeneral(message: "Is already my friend.")
        }
        
        let friendId = friend.friendId
        let senderId = sender.id
        
        let queryToGetFriendRequestBySender = FetchDescriptor<FriendRequest>(
            predicate: #Predicate {
                $0.from.friendId == senderId
                && $0.to.friendId == friendId
             },sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        )
        
        let existingFriendRequest = try context.fetch(queryToGetFriendRequestBySender)
        
        if let active = existingFriendRequest.first(where: { $0.status == .pending }) {
            print("❌ A pending request already exists: \(active.id)")
            throw UserError.friendAlreadySent
        }

        
        if let reusable = existingFriendRequest.first(where: { friendRequest in
            friendRequest.status == .canceled
            || friendRequest.status == .declined
        }) {
            print("Reusing friend request")
            reusable.updateStatus(to: .pending)
            try context.save()
            return
        }
        
        print("Creating a new Request...")
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
        
        guard friendRequest.belogsToUser(withId: userId) else {
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
    
    func acceptFriendRequest(with id: UUID) async throws {
        
        // get friend request
        let friendRequest = try await fetchFriendRequest(withId: id)
        
        // get users involved
        let senderUser = try await fetchUser(withId: friendRequest.from.friendId)
        let receiverUser = try await fetchUser(withId: friendRequest.to.friendId)
        
        // update friend relationship for each friend
        senderUser.addFriend(user: receiverUser)
        receiverUser.addFriend(user: senderUser)
        
        // upadte friend request status 
        friendRequest.updateStatus(to: .accepted)
        
        try context.save()
    }
    
    func acceptMission(with id: UUID) async throws {
        
        guard let receiver = user else {
            throw UserError.invalidUser(message: "User is not logged in or cannot find user in session")
        }
        
        let missionRequest = try await fetchMissionRequest(withId: id)
        
        receiver.addMission(missionRequest.mission.asCopy())
        missionRequest.updateStatus(to: .accepted)
        
        try context.save()
    }
        
    @discardableResult
    func removeFriendFromList(friend: Friend) async throws -> Bool {
        guard let currentUser = user else {
            throw UserError.invalidUser(message: "Cannot find user information")
        }

        guard currentUser.hasFriend(withId: friend.friendId) else {
            throw UserError.friendGeneral(message: "This user does not belong to you.")
        }

        // Fetch the other user (the friend)
        let friendUser = try await fetchUser(withId: friend.friendId)
        

        // Find and delete the reciprocal Friend object from the friend's list
        if let reciprocal = friendUser.friends.first(where: { $0.friendId == currentUser.id }) {
            print("Deleting my reference from friend: \(reciprocal.username)")
            
            friendUser.friends.removeAll(where: {$0.friendId == reciprocal.friendId})
            context.delete(reciprocal)
        }
        
        currentUser.friends.removeAll(where: {$0.friendId == friendUser.id })
        context.delete(friend)

        try context.save()
        return true
    }
    
    func declineFriendRequest(with id: UUID) async throws {
        try await updateFriendRequestStatus(withId: id, to: .declined)
    }
    
    func declineMissionRequest(withId id: UUID) async throws -> Void {
        try await updateMissionStatus(withId: id, to: .declined)
    }
    
    @discardableResult
    private func updateFriendRequestStatus(withId id: UUID, to status: AppNotification.StatusNotification)
    async throws -> FriendRequest {
        
        let friendRequest = try await fetchFriendRequest(withId: id)
   
        friendRequest.updateStatus(to: status)
        
        try context.save()
        
        return friendRequest
    }
    
    @discardableResult
    private func updateMissionStatus(withId id: UUID, to status: AppNotification.StatusNotification)
    async throws -> MissionRequest {
        
        let missionRequest = try await fetchMissionRequest(withId: id)
             
        missionRequest.updateStatus(to: status)
        
        try context.save()
        
        return missionRequest
    }
    
    private func fetchUser(withId id: UUID) async throws -> User {
        let descriptor = FetchDescriptor<User>(
            predicate: #Predicate { $0.id == id }
        )
        guard let user = try context.fetch(descriptor).first else {
            throw UserError.notFound
        }
        return user
    }
    
    func fetchFriendRequest(withId id: UUID) async throws -> FriendRequest {
        
        guard let userId = user?.id else {
            throw UserError.invalidUser(message: "Cannot find user information")
        }
        
        let descriptor = FetchDescriptor<FriendRequest>(
            predicate: #Predicate { $0.id == id && $0.from.friendId == userId || $0.to.friendId == userId }
        )
        
        guard let request = try context.fetch(descriptor).first else {
            print("⚠️ No FriendRequest found with id: \(id)")
            throw UserError.notFound
        }
        
        return request
    }
    
    func fetchMissionRequest(withId id: UUID) async throws -> MissionRequest {
        
        guard let userId = user?.id else {
            throw UserError.invalidUser(message: "Cannot find user information")
        }
        
        let queryToGetMission = FetchDescriptor<MissionRequest>(
            predicate: #Predicate {
                $0.id == id
                && ($0.from.friendId == userId
                    ||  $0.to.friendId == userId)
            }
        )
        
        guard let foundMissionRequest = try context.fetch(queryToGetMission).first else {
            print("⚠️ No MissionRequest found with id: \(id)")
            throw UserError.notFound
        }
        
        return foundMissionRequest
    }
}
