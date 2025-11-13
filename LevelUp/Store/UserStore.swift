//
//  UserStore.swift
//  LevelUp
//
//  Created by Raúl Pichardo Avalo on 9/12/25.
//

import Foundation
import SwiftUI
import SwiftData

@MainActor
final class UserStore: ObservableObject {
    @AppStorage("activeUserId") private var activeUserId: String?
    @Published var user: User? = nil
    private(set) var userController: UserController?
    
    // 🔹 Splash state for global loading indicators (like login/logout)
    @Published var isBusy: Bool = false
    @Published var busyMessage: String? = nil

    init(context: ModelContext? = nil) {
        if let context {
            self.userController = UserController(context: context)
        }
    }

    func attachContext(_ context: ModelContext) {
        if userController == nil {
            self.userController = UserController(context: context)
        }
    }

    // MARK: - Authentication
    func login(identifier: String, password: String) async throws {
        guard let controller = userController else {
            fatalError("UserController not initialized")
        }

        // 🔹 Start busy state
        isBusy = true
        busyMessage = "Logging in..."

        do {
//            try await Task.sleep(nanoseconds: 1_000_000_000 * 2) // 2s

            let foundUser = try await controller.authenticate(identifier: identifier, password: password)
            self.user = foundUser
            activeUserId = foundUser.id.uuidString
            print("✅ Logged in as \(foundUser.username)")
        } catch {
            print("❌ Login failed: \(error)")
            isBusy = false
            busyMessage = nil
            throw error
        }

        // 🔹 End busy state
        isBusy = false
        busyMessage = nil
    }

    func signUp(username: String, email: String, password: String) async throws {
        guard let controller = userController else {
            fatalError("UserController not initialized")
        }

        // 🔹 Start busy state
        isBusy = true
        busyMessage = "Creating your account..."

        do {
            let newUser = try controller.createUser(username: username, email: email, password: password)
            self.user = newUser
            activeUserId = newUser.id.uuidString
            print("🆕 Created user: \(newUser.username)")
        } catch {
            print("❌ Sign up failed: \(error)")
            isBusy = false
            busyMessage = nil
            throw error
        }

        // 🔹 End busy state
        isBusy = false
        busyMessage = nil
    }
    
    func setUser(_ user: User) {
        self.user = user
        activeUserId = user.id.uuidString
    }

    // MARK: - Logout (local)
    func logout() {
        print("🚪 Logging out user: \(user?.username ?? "Unknown")")
        self.user = nil
        activeUserId = nil
    }

    // MARK: - Logout (async / network-ready)
    func logoutAsync() async {
        // Start splash animation
        isBusy = true
        busyMessage = "Signing out..."

        do {
            // Simulate or replace this with a real network call later
            try await Task.sleep(nanoseconds: 200_000_000) // 0.2s for polish

            // Example future call:
            // try await userController?.remoteLogout(userId: user?.id)
            
            logout()
            print("✅ User successfully logged out.")
        } catch {
            print("❌ Logout failed: \(error)")
            isBusy = false
            busyMessage = nil
        }

        // End splash animation
        isBusy = false
        busyMessage = nil
    }

    // MARK: - Utility
    func getActiveUserId() -> UUID? {
        guard let idString = activeUserId else { return nil }
        return UUID(uuidString: idString)
    }
    
    func setActiveUserId(_ id: UUID?) {
        self.activeUserId = id?.uuidString
    }
    
    func validateUserPassword(_ password: String) -> Bool {
        guard let user else {
            print("⚠️ UserController or user not available.")
            return false
        }
        
        // Hash the provided password
        let hashedInput = UserController.hash(password)
        
        // Compare against the stored hash
        let isValid = hashedInput == user.passwordHash
        
        print(isValid ? "✅ Password validated successfully" : "❌ Invalid password")
        return isValid
    }
    
    func isPasswordValid(_ password: String) -> Bool {
        let regex = try! NSRegularExpression(
            pattern: "^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d).{4,}$"
        )
        return regex.firstMatch(in: password, range: NSRange(password.startIndex..., in: password)) != nil
    }
    
    @discardableResult
    func validateUsername(_ username: String) async throws -> Bool {
        let trimmed = username.trimmingCharacters(in: .whitespacesAndNewlines)

        // 1️⃣ Empty check
        guard !trimmed.isEmpty else {
            throw UsernameValidationError.empty
        }

        // 2️⃣ Length check
        guard trimmed.count >= 3 else {
            throw UsernameValidationError.tooShort
        }

        guard trimmed.count <= 20 else {
            throw UsernameValidationError.tooLong
        }

        // 3️⃣ Character validation
        let regex = try! NSRegularExpression(pattern: "^[A-Za-z0-9._]+$")
        let range = NSRange(location: 0, length: trimmed.utf16.count)
        guard regex.firstMatch(in: trimmed, range: range) != nil else {
            throw UsernameValidationError.invalidCharacters
        }

        // 4️⃣ Duplicate check
        if let controller = userController {
            do {
                let existingUser = try await controller.searchUsers(byUsername: trimmed)

                if !existingUser.isEmpty {
                    throw UsernameValidationError.usernameTaken
                }
            } catch let error as UsernameValidationError {
                // Re-throw your intentional validation errors
                throw error
            } catch {
                // Only handle unexpected (e.g. network/database) errors here
                print("⚠️ Username lookup failed: \(error)")
                throw UsernameValidationError.lookupFailed
            }
        }

        // ✅ All checks passed
        return true
    }
    
    func emcrypPassword(_ password: String) -> String {        
        UserController.hash(password)
    }
}

// MARK: - Environment Injection
struct CurrentUserKey: EnvironmentKey {
    static var defaultValue: User {
        #if DEBUG
        return User.sampleUser() // safe fallback in previews
        #else
        fatalError("User is not logged in. Please login first.")
        #endif
    }
}


extension EnvironmentValues {
    var currentUser: User {
        get { self[CurrentUserKey.self] }
        set { self[CurrentUserKey.self] = newValue }
    }
}


enum UsernameValidationError: LocalizedError {
    case empty
    case tooShort
    case tooLong
    case invalidCharacters
    case usernameTaken
    case lookupFailed

    var errorDescription: String? {
        switch self {
        case .empty:
            "Username cannot be empty."
        case .tooShort:
            "Username must be at least 3 characters long."
        case .tooLong:
            "Username cannot exceed 20 characters."
        case .invalidCharacters:
            "Username can only contain letters, numbers, underscores, or dots."
        case .usernameTaken:
            "This username is already taken."
        case .lookupFailed:
            "Something went wrong while checking the username."
        }
    }
}
