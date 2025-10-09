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
//            try await Task.sleep(nanoseconds: 1_000_000_000 * 5) // 5s

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
