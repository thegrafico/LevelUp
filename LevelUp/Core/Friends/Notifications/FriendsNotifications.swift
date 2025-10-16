//
//  FriendsNotifications.swift
//  LevelUp
//
//  Created by Raúl Pichardo Avalo on 10/11/25.
//

import SwiftUI

struct FriendsNotifications: View {
    @Environment(\.theme) private var theme
    @Environment(\.dismiss) private var dismiss
    
    @State private var expandedSections: Set<AppNotification.Kind> = [.friendRequest]
    
    var notifications: [AppNotification]
    @State private var selectedNotification: AppNotification? = nil
    
    
    var groupedNotifications: [AppNotification.Kind: [AppNotification]] {
        Dictionary(grouping: notifications, by: { $0.kind })
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                if notifications.isEmpty {
                    EmptyNotificationsView()
                } else {
                    // 👇 Your existing content
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 20) {
                            ForEach(AppNotification.Kind.allCases, id: \.self) { type in
                                let items = groupedNotifications[type] ?? []
                                
                                if !items.isEmpty {
                                    NotificationSection(
                                        title: type.rawValue,
                                        notifications: items,
                                        isExpanded: expandedSections.contains(type),
                                        onToggle: {
                                            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                                if expandedSections.contains(type) {
                                                    expandedSections.remove(type)
                                                } else {
                                                    expandedSections.insert(type)
                                                }
                                            }
                                        },
                                        onViewTap: { notification in
                                            selectedNotification = notification
                                        }
                                    )
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 20)
                    }
                    .background(theme.background.ignoresSafeArea())
                }
            }
            .navigationTitle("Notifications")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .symbolRenderingMode(.monochrome)
                            .font(.title3)
                            .foregroundStyle(theme.textSecondary.opacity(0.7))
                    }
                    .buttonStyle(.plain)
                }
            }
            .background(theme.background.ignoresSafeArea())
        }
        .sheet(item: $selectedNotification) { notification in
            if let friend = notification.sender {
                FriendPreviewCard(friend: friend, actionTitle: notification.actionTitle)
                    .presentationDetents([.medium])
            }
        }
        .interactiveDismissDisabled(true)
        .presentationDetents([.fraction(1.0)])
        .presentationDragIndicator(.hidden)

        
        .sheet(item: $selectedNotification) { notification in
            if let friend = notification.sender {
            
                FriendPreviewCard(friend: friend, actionTitle: notification.actionTitle)
                    .presentationDetents([.medium])
            }
            
        }
        
        .interactiveDismissDisabled(true)
        .presentationDetents([.fraction(1.0)])  // full height
        .presentationDragIndicator(.hidden)
        .onAppear {
            print("List of Notifications Count:  \(self.notifications.count)")
        }
    }
}

#Preview {
    FriendsNotifications(notifications: SampleData.sampleAppNotifications)
}
