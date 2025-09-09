//
//  Friends.swift
//  LevelUp
//
//  Created by Raúl Pichardo Avalo on 9/8/25.
//

import SwiftUI

// MARK: - UI Model (demo)
struct UIFriend: Identifiable {
    let id = UUID()
    var name: String
    var username: String
    var avatar: String   // SF Symbol
    var isOnline: Bool
}



private let demoFriends: [UIFriend] = [
    .init(name: "Ava",    username: "@ava",    avatar: "person.circle.fill", isOnline: true),
    .init(name: "Liam",   username: "@liam",   avatar: "person.crop.circle.fill", isOnline: false),
    .init(name: "Maya",   username: "@maya",   avatar: "person.fill", isOnline: true),
    .init(name: "Noah",   username: "@noah",   avatar: "person.fill", isOnline: false),
    .init(name: "Sofia",  username: "@sofia",  avatar: "person.fill", isOnline: true),
]

struct FriendsHeader: View {
    @Environment(\.theme) private var theme
    var height: CGFloat = 200
    var radius: CGFloat = 0

    var body: some View {
        TopBannerBackground(height: height, radius: radius)
            .overlay(alignment: .bottomLeading) {     // <- text sits ON the banner
                VStack(alignment: .leading, spacing: 6) {
                    Text("FRIENDS")
                        .font(.system(size: 34, weight: .black, design: .rounded))
                        .kerning(1.5)
                        .foregroundStyle(theme.textInverse)
                    Text("Find and add friends")
                        .font(.headline)
                        .foregroundStyle(theme.textInverse.opacity(0.85))
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 14)
            }
            .frame(height: height)
            .ignoresSafeArea(edges: .top)
    }
}

// MARK: - Friends View
struct FriendsView: View {
    @Environment(\.theme) private var theme
    @State private var query: String = ""
    @State private var showAddSheet = false

    @State private var friends: [UIFriend] = demoFriends

    var filtered: [UIFriend] {
        let q = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !q.isEmpty else { return friends }
        return friends.filter { $0.name.localizedCaseInsensitiveContains(q) || $0.username.localizedCaseInsensitiveContains(q) }
    }

    var body: some View {
        VStack(spacing: 16) {
            // Banner header with title on top of gradient
            FriendsHeader(height: 200, radius: 0)
            
            VStack {
                
                
                // Add button row
                HStack {
                    Spacer()
                    
                }
                .padding(.horizontal, 20)
                
                // Search
                HStack(spacing: 8) {
                    Image(systemName: "magnifyingglass").foregroundStyle(theme.textSecondary)
                    TextField("Search friends", text: $query)
                        .textInputAutocapitalization(.never)
                        .disableAutocorrection(true)
                    
                    Button { showAddSheet = true } label: {
                        Label("Add", systemImage: "person.badge.plus")
                            .labelStyle(.iconOnly)
                            .font(.title3.weight(.semibold))
                            .foregroundStyle(theme.primary)
                            .padding(10)
                            .background(
                                RoundedRectangle(cornerRadius: theme.cornerRadiusSmall)
                                    .fill(theme.primary.opacity(0.12))
                            )
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .background(theme.cardBackground)
                .clipShape(RoundedRectangle(cornerRadius: theme.cornerRadiusLarge, style: .continuous))
                .shadow(color: theme.shadowLight, radius: 6, y: 3)
                .padding(.horizontal, 20)
                
                // Only the list scrolls
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(filtered) { f in
                            FriendRow(friend: f)
                                .padding(.horizontal, 20)
                        }
                    }
                    .padding(.vertical, 8)
                }
                .scrollIndicators(.hidden)
                
                Spacer(minLength: 0)
            }
            .frame(maxHeight: .infinity, alignment: .top)
            .sheet(isPresented: $showAddSheet) {
                AddFriendsSheet()
                    .presentationDetents([.height(360), .medium])
            }
            .offset(y: -60)
        }
        .background(theme.background.ignoresSafeArea())

    }
}

// MARK: - Friend Row
struct FriendRow: View {
    @Environment(\.theme) private var theme
    var friend: UIFriend
    
    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: theme.cornerRadiusSmall, style: .continuous)
                    .fill(friend.isOnline ? theme.primary.opacity(0.18) : theme.textPrimary.opacity(0.08))
                    .frame(width: 48, height: 48)
                Image(systemName: friend.avatar)
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundStyle(friend.isOnline ? theme.primary : theme.textSecondary)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 6) {
                    Text(friend.name)
                        .font(.headline.weight(.semibold))
                        .foregroundStyle(theme.textPrimary)
                    if friend.isOnline {
                        Circle().fill(theme.primary).frame(width: 6, height: 6)
                    }
                }
                Text(friend.username)
                    .font(.subheadline)
                    .foregroundStyle(theme.textSecondary)
            }
            Spacer()
            
            // Placeholder action (e.g., view profile / challenge)
            Button {
                // wire later
            } label: {
                Text("Challenge")
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(theme.primary)
                    .padding(.horizontal, 10).padding(.vertical, 8)
                    .background(Capsule().fill(theme.primary.opacity(0.1)))
            }
            .buttonStyle(.plain)
        }
        .padding(12)
        .background(theme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: theme.cornerRadiusLarge, style: .continuous))
        .shadow(color: theme.shadowLight, radius: 6, y: 3)
    }
}

// MARK: - Add Friends Sheet
struct AddFriendsSheet: View {
    @Environment(\.theme) private var theme
    @State private var inviteCode: String = ""
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                // Connect Facebook (placeholder)
                Button {
                    // TODO: integrate FB SDK or Contacts
                } label: {
                    HStack(spacing: 12) {
                        ZStack {
                            RoundedRectangle(cornerRadius: theme.cornerRadiusSmall)
                                .fill(theme.primary.opacity(0.12))
                                .frame(width: 40, height: 40)
                            Image(systemName: "f.cursive.circle.fill")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundStyle(theme.primary)
                        }
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Connect Facebook")
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(theme.textPrimary)
                            Text("Find friends from your contacts")
                                .font(.footnote)
                                .foregroundStyle(theme.textSecondary)
                        }
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundStyle(theme.textSecondary)
                    }
                    .padding(14)
                    .background(theme.cardBackground)
                    .clipShape(RoundedRectangle(cornerRadius: theme.cornerRadiusLarge))
                    .shadow(color: theme.shadowLight, radius: 6, y: 3)
                }
                .buttonStyle(.plain)
                .padding(.horizontal, 16)
                
                // Or add by code
                VStack(alignment: .leading, spacing: 10) {
                    Text("Add by Code")
                        .font(.headline.weight(.semibold))
                        .foregroundStyle(theme.textPrimary)
                    
                    HStack(spacing: 10) {
                        TextField("Enter code (e.g., 7F4Q-92K)", text: $inviteCode)
                            .textInputAutocapitalization(.never)
                            .disableAutocorrection(true)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 10)
                            .background(theme.cardBackground)
                            .clipShape(RoundedRectangle(cornerRadius: theme.cornerRadiusSmall))
                            .overlay(
                                RoundedRectangle(cornerRadius: theme.cornerRadiusSmall)
                                    .stroke(theme.textPrimary.opacity(0.08), lineWidth: 1)
                            )
                        
                        Button {
                            // TODO: validate & add friend
                        } label: {
                            Text("Add")
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(theme.textInverse)
                                .padding(.horizontal, 14)
                                .padding(.vertical, 10)
                                .background(
                                    RoundedRectangle(cornerRadius: theme.cornerRadiusSmall)
                                        .fill(theme.primary)
                                )
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(16)
                .background(theme.cardBackground)
                .clipShape(RoundedRectangle(cornerRadius: theme.cornerRadiusLarge))
                .shadow(color: theme.shadowLight, radius: 6, y: 3)
                .padding(.horizontal, 16)
                
                Spacer()
            }
            .padding(.top, 12)
            .background(theme.background.ignoresSafeArea())
            .navigationTitle("Add Friends")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    FriendsView()
        .environment(\.theme, .orange)
}
