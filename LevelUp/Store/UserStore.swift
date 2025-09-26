//
//  UserStore.swift
//  LevelUp
//
//  Created by Raúl Pichardo Avalo on 9/12/25.
//

import Foundation
import SwiftUI

final class UserStore: ObservableObject {
    @Published var user: User? = nil

    // maybe convenience initializer
    init(user: User? = nil) {
        self.user = user
    }
}


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
