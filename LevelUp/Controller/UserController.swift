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
    
    func searchUsers(byUsername query: String) async throws -> [User] {
           let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
           guard !trimmed.isEmpty else { return [] }

           let descriptor = FetchDescriptor<User>(
               predicate: #Predicate { user in
                   user.username.localizedStandardContains(trimmed)
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
