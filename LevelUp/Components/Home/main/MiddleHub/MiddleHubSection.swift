//
//  MiddleHubSection.swift
//  LevelUp
//
//  Created by Raúl Pichardo Avalo on 9/26/25.
//

import SwiftUI

struct MiddleHubSection: View {
    @Environment(\.theme) private var theme
    @State private var showQuickActions = false
    @State private var showUserProgress = false


    var body: some View {
        HStack(spacing: 12) {
            
            // MARK: LEFT: Quick Actions (tappable)
            QuickActionsView(showActionsSheet: $showQuickActions)
            
            // VERTICAL DIVIDER
            Rectangle()
                .fill(theme.textPrimary.opacity(0.12))
                .frame(width: 1, height: 36)
                .cornerRadius(0.5)
            
            // MARK: RIGHT: Today's Progress
            TodayProgress(showTodaysProgressSheet: $showUserProgress)
            
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(theme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: theme.cornerRadiusLarge, style: .continuous))
        .shadow(color: theme.shadowLight, radius: 8, y: 4)
        .shadow(color: theme.shadowDark, radius: 16, y: 10)
        .sheet(isPresented: $showQuickActions) {
            QuickActionsSheet()
                .presentationDetents([.medium, .large])
                .background(theme.background.ignoresSafeArea())       
        }
        .sheet(isPresented: $showUserProgress) {
            UserProgressSheet()
                .presentationDetents([.large])
                       .presentationDragIndicator(.visible)
                       .presentationBackgroundInteraction(.enabled(upThrough: .large))
                       .scrollBounceBehavior(.basedOnSize) // 👈 new in iOS 17+
                       .background(theme.background.ignoresSafeArea())
        }
        .padding(.horizontal, 30)
        .padding(.bottom, 12)
    }
}


#Preview {
    MiddleHubSection()
        .environment(\.currentUser, User.sampleUser())

}
