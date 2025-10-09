//
//  NotificationManager.swift
//  LevelUp
//
//  Created by Raúl Pichardo Avalo on 10/9/25.
//

import Foundation
import SwiftUI

struct GlobalNotification: Identifiable, Equatable {
    let id = UUID()
    var title: String
    var message: String?
    var icon: String?
    var style: Style = .info
    
    enum Style {
        case success, error, warning, info
    }
}

@MainActor
final class GlobalNotificationStore: ObservableObject {
    @Published var activeNotification: GlobalNotification? = nil

    func show(_ notification: GlobalNotification, duration: TimeInterval = 3) {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            activeNotification = notification
        }

        Task {
            try? await Task.sleep(nanoseconds: UInt64(duration * 1_000_000_000))
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                activeNotification = nil
            }
        }
    }

    func hide() {
        withAnimation(.easeOut(duration: 0.3)) {
            activeNotification = nil
        }
    }
}
