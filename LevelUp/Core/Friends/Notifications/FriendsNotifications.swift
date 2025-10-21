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
    
    @State private var expandedSections: Set<AppNotification.Kind> = [.friendRequest, .challenge]
    
    var notifications: [AppNotification]
    @State private var localNotifications: [AppNotification] = []
    @State private var selectedNotification: AppNotification? = nil
    
    
    var groupedNotifications: [AppNotification.Kind: [AppNotification]] {
        Dictionary(grouping: notifications, by: { $0.kind })
    }
    
    var userController: UserController? = nil
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                ZStack {
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
                                    .transition(.asymmetric(
                                        insertion: .opacity.combined(with: .scale),
                                        removal: .opacity.combined(with: .scale)
                                    ))
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 20)
                    }

                    if notifications.isEmpty {
                        EmptyNotificationsView()
                            .transition(.opacity.combined(with: .scale))
                    }
                }
                .animation(.easeInOut(duration: 0.4), value: notifications.count)
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
                FriendPreviewCard(
                    friend: friend,
                    type: notification.kind,
                    onAction: { _ in
                        await acceptNotification(notification)
                    },
                    onCancel: { _ in
                        await declinedNotification(notification)
                    }
                )
                .presentationDetents([.medium])
            }
        }
        .onAppear {
            print("Controller: \(String(describing: userController))")
        }
        .interactiveDismissDisabled(true)
        .presentationDetents([.fraction(1.0)])  // full height
        .presentationDragIndicator(.hidden)
    }
    
    private func acceptNotification(_ notification: AppNotification) async {
        print("Accepting notification")
        
        guard let controller = userController else {
            print("Controller not found")
            return
        }
       
        await MainActor.run {
            withAnimation(.easeInOut(duration: 0.25)) {
                selectedNotification = nil
            }
        }
        
        print("accepting now...")
        try? await controller.acceptNotification(notification)

    }
    
    
    private func declinedNotification(_ notification: AppNotification) async {
        print("Declining notification…")
        
        guard let controller = userController else {
            print("Controller not found")
            return
        }
        
        await MainActor.run {
            withAnimation(.easeInOut(duration: 0.25)) {
                selectedNotification = nil
            }
        }
        
        try? await Task.sleep(nanoseconds: 500_000_000)
        
        print("Declining now...")
        try? await controller.declineNotification(notification)
        
    }
}

#Preview {
    FriendsNotifications(notifications: SampleData.sampleAppNotifications)
}
