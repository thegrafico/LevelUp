//
//  AppTopBanner.swift
//  LevelUp
//
//  Created by Raúl Pichardo Avalo on 10/11/25.
//

import SwiftUI


struct AppTopBanner: View {
    @Environment(\.theme) private var theme    
    @Environment(BadgeManager.self) private var badgeManager: BadgeManager?

    var title: String
    var subtitle: String
    var onNotificationTap: (() -> Void)? = nil
    
    var height: CGFloat = 200
    var radius: CGFloat = 0
    
    var body: some View {
        TopBannerBackground(height: height, radius: radius)
            .overlay(alignment: .bottomLeading) {
                HStack(alignment: .bottom) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(title)
                            .font(.system(size: 34, weight: .black, design: .rounded))
                            .kerning(1.5)
                            .foregroundStyle(theme.textInverse)
                        Text(subtitle)
                            .font(.headline)
                            .foregroundStyle(theme.textInverse.opacity(0.85))
                    }
                    
                    Spacer()
                    
                    Button {
                        UIImpactFeedbackGenerator(style: .soft).impactOccurred()
                        badgeManager?.clear(.FriendsNotification)
                        onNotificationTap?()
                    } label: {
                        Image(systemName: "bell.badge.fill")
                            .font(.system(size: 22, weight: .semibold))
                            .foregroundStyle(theme.textInverse.opacity(0.9))
                            .padding(10)
                            .background(
                                Circle()
                                    .fill(theme.textInverse.opacity(0.1))
                            )
                    }
                    .buttonStyle(.plain)    
                    .overlay(alignment: .topTrailing) {
                        if let badgeManager = badgeManager {
                            
                            let count = badgeManager.count(for: .FriendsNotification)
                            if count > 0 {
                                BadgeView(count: count, size: 30)
                                    .offset(x: 6, y: -14)
                            } else {
                                EmptyView()
                            }
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 14)
            }
            .frame(height: height)
            .ignoresSafeArea(edges: .top)
    }
}

#Preview {
    AppTopBanner(title: "Friends", subtitle: "Add or challenge them!")
        .environment(BadgeManager()) // 👈 inject preview manager

}
