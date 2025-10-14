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
    private let context: ModelContext
    
    init(context: ModelContext) {
        self.context = context
    }
    
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
        case usernameOrEmailTaken
        case usernameTaken
        case emailTaken
        case invalidInput
        
        var errorDescription: String? {
            switch self {
            case .emailTaken: return "This email is already registered."
            case .invalidInput: return "Invalid user information."
            case .usernameOrEmailTaken: return "This username or email is already registered."
            case .usernameTaken: return "This username is already registered."
                
            }
        }
    }
}

extension UserController {
    
    func fetchPendingFriendRequests(for user: User) async throws -> [FriendRequest] {
        
        let pendingStatus: String = friendRequestStatus.pending.rawValue
        let userId: UUID = user.id
        print("User: \(user.username), id: \(userId)")
        let descriptor = FetchDescriptor<FriendRequest>(
            predicate: #Predicate { request in
                request.statusRaw == pendingStatus
                 && request.from.friendId == userId
            }
//            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        )
        
        return try context.fetch(descriptor)
    }
    
    func sendFriendRequest(from sender: User, to receiverId: UUID) async throws -> Void {
        print("Sending request...")
        
        
        try await Task.sleep(nanoseconds: 1_000_000_000) // 2s
        
        let senderId = sender.id
        let descriptor = FetchDescriptor<FriendRequest>(
            predicate: #Predicate { $0.from.friendId == senderId && $0.to == receiverId}
        )
        
        let existing = try context.fetch(descriptor)
        
        for exist in existing {
            print("Existing: \(exist)")
        }
        
        if !existing.isEmpty {
            throw FriendRequestError.alreadySent
        }
        
        let request = FriendRequest(
            from: sender.asFriend(),
            to: receiverId,
            status: .pending
        )
        do {
            context.insert(request)
            try context.save()
            print("Friend Request sent sucessfully!: From: \(request.from.friendId) to: \(request.to)")
        }catch {
            print("There was an error: \(error)")
            throw FriendRequestError.generalError
        }
        
    }
    
    func deleteAllFriendRequest(for user: User) async throws -> Void {
        let userId: UUID = user.id
        let descriptorPredicate = #Predicate<FriendRequest> { req in
            req.from.friendId == userId
        }
        try context.delete(model: FriendRequest.self, where: descriptorPredicate)

        try context.save()
    }
    
    enum FriendRequestError: LocalizedError {
        case alreadySent
        case invalidTarget
        case generalError
        
        var errorDescription: String? {
            switch self {
            case .alreadySent:
                return "Friend request already sent."
            case .invalidTarget:
                return "Invalid friend target."
                
            case .generalError:
                return "Oops, Something went wrong. Try again later."
            }
        }
    }
}
