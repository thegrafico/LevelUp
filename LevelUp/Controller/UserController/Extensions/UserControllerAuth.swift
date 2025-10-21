//
//  UserControllerAuth.swift
//  LevelUp
//
//  Created by Raúl Pichardo Avalo on 10/20/25.
//

import Foundation
import SwiftData

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
}
