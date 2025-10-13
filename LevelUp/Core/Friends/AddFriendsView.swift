//
//  AddFriendsView.swift
//  LevelUp
//
//  Created by Raúl Pichardo Avalo on 10/11/25.
//

import SwiftUI

private let demoUsers: [Friend] = [
    .init(username: "Thegrafico", stats: .init(level: 22, topMission: "Drink Water")),
    .init(username: "SwiftMaster", stats: .init(level: 14, topMission: "Daily Run")),
    .init(username: "CodeNinja", stats: .init(level: 18, topMission: "Read Books")),
    .init(username: "UIQueen", stats: .init(level: 25, topMission: "Design Sprint")),
]

struct AddFriendsView: View {
    @Environment(\.theme) private var theme
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    
    private var userController: UserController {
        .init(context: context)
    }
    
    @State private var username: String = ""
    @State private var searchResults: [Friend] = []
    @State private var hasSearched = false
    
    
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
                    Text("Add by Username")
                        .font(.headline.weight(.semibold))
                        .foregroundStyle(theme.textPrimary)
                    
                    HStack(spacing: 10) {
                        TextField("e.g., thegrafico", text: $username)
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
                            UIImpactFeedbackGenerator(style: .soft).impactOccurred()
                            performSearch()
                        } label: {
                            Text("Search")
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
                    
                    if hasSearched {
                        if searchResults.isEmpty {
                            VStack(spacing: 12) {
                                HStack {
                                    Spacer()
                                    Image(systemName: "person.fill.questionmark")
                                        .font(.largeTitle)
                                        .foregroundStyle(theme.primary)
                                    Text("No users found")
                                        .font(.headline)
                                        .foregroundStyle(theme.textSecondary)
                                    Spacer()
                                }
                            }.padding(.top, 20)
                        } else {
                            ScrollView {
                                LazyVStack(spacing: 12) {
                                    ForEach(searchResults) { user in
                                        HStack(spacing: 12) {
                                            Circle()
                                                .fill(theme.primary.opacity(0.15))
                                                .frame(width: 48, height: 48)
                                                .overlay(
                                                    Image(systemName: "person.fill")
                                                        .font(.system(size: 20, weight: .semibold))
                                                        .foregroundStyle(theme.primary)
                                                )
                                            
                                            VStack(alignment: .leading) {
                                                Text(user.username)
                                                    .font(.headline.weight(.semibold))
                                                    .foregroundStyle(theme.textPrimary)
                                                Text("Level \(user.stats.level)")
                                                    .font(.subheadline)
                                                    .foregroundStyle(theme.textSecondary)
                                            }
                                            
                                            Spacer()
                                            
                                            Button {
                                                UIImpactFeedbackGenerator(style: .soft).impactOccurred()
                                                // TODO: send friend request
                                            } label: {
                                                Text("Add")
                                                    .font(.footnote.weight(.semibold))
                                                    .foregroundStyle(theme.primary)
                                                    .padding(.horizontal, 10)
                                                    .padding(.vertical, 8)
                                                    .background(Capsule().fill(theme.primary.opacity(0.1)))
                                            }
                                            .buttonStyle(.plain)
                                        }
                                        .padding(12)
                                        .background(theme.cardBackground)
                                        .clipShape(RoundedRectangle(cornerRadius: theme.cornerRadiusLarge))
                                        .shadow(color: theme.shadowLight, radius: 6, y: 3)
                                        .padding(.horizontal, 16)
                                    }
                                }
                                .padding(.top, 10)
                            }
                        }
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
            
            .navigationTitle("Add Friends")
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
    }
    
    private func performSearch() {
        Task {
            let query = username.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !query.isEmpty else {
                searchResults = []
                hasSearched = false
                return
            }
            
            do {
                let users: [User] = try await userController.searchUsers(byUsername: query)
                await MainActor.run {
                    hasSearched = true
                    // Transform your User → Friend or any display model
                    searchResults = users.map { user in
                        Friend(username: user.username, stats: user.stats)
                    }
                }
            } catch {
                print("❌ Search failed: \(error.localizedDescription)")
                await MainActor.run {
                    hasSearched = true
                    searchResults = []
                }
            }
        }
    }
}

#Preview {
    AddFriendsView()
        .modelContainer(SampleData.shared.modelContainer)
        .environment(\.theme, .orange)
        .environment(\.currentUser, User.sampleUserWithLogs())
}
