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
    let badgeManager: BadgeManager?
    let user: User?
    
    init(context: ModelContext, user: User? = nil, badgeManager: BadgeManager? = nil) {
        self.context = context
        self.user = user
        self.badgeManager = badgeManager
    }
}


// MARK: ENUMS
extension UserController {
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
        case notFound

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
            case .notFound:
                return "Not Found."
            }
        }
    }
}
