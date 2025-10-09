//
//  GlobalNotificationView.swift
//  LevelUp
//
//  Created by Raúl Pichardo Avalo on 10/9/25.
//

import SwiftUI

struct GlobalNotificationView: View {
    @Environment(\.theme) private var theme
    let notification: GlobalNotification

    private var backgroundStyle: some ShapeStyle {
        switch notification.style {
        case .success: return LinearGradient(colors: [.green.opacity(0.9), .green.opacity(0.7)], startPoint: .topLeading, endPoint: .bottomTrailing)
        case .error: return LinearGradient(colors: [.red.opacity(0.9), .red.opacity(0.7)], startPoint: .topLeading, endPoint: .bottomTrailing)
        case .warning: return LinearGradient(colors: [.orange.opacity(0.9), .yellow.opacity(0.7)], startPoint: .topLeading, endPoint: .bottomTrailing)
        case .info: return LinearGradient(colors: [theme.primary.opacity(0.9), theme.primary.opacity(0.7)], startPoint: .topLeading, endPoint: .bottomTrailing)
        }
    }

    var body: some View {
        HStack(spacing: 12) {
            if let icon = notification.icon {
                Image(systemName: icon)
                    .font(.headline.bold())
                    .foregroundStyle(.white)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(notification.title)
                    .font(.subheadline.bold())
                    .foregroundStyle(.white)

                if let message = notification.message {
                    Text(message)
                        .font(.footnote)
                        .foregroundStyle(.white.opacity(0.8))
                }
            }

            Spacer()

            Button {
                // TODO: dismiss manually if needed
            } label: {
                Image(systemName: "xmark")
                    .font(.caption.bold())
                    .foregroundStyle(.white.opacity(0.8))
                    .padding(6)
            }
        }
        .padding(14)
        .background(backgroundStyle)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .shadow(radius: 6, y: 4)
        .padding(.horizontal, 16)
        .transition(.move(edge: .top).combined(with: .opacity))
    }
}

#Preview {
    GlobalNotificationView(notification: GlobalNotification(title: "Test", message: "Success", icon: "plus", style: .success))
    
    GlobalNotificationView(notification: GlobalNotification(title: "Test", message: "Error", icon: "plus", style: .error))
    
    
    GlobalNotificationView(notification: GlobalNotification(title: "Test", message: "Warning", icon: "plus", style: .warning))
    
    GlobalNotificationView(notification: GlobalNotification(title: "Test", message: "Info", icon: "plus", style: .info))
}
