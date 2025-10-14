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
    @State private var isLoading = false
    
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                
                // Connect Facebook (placeholder)
                ConnectToSocialView()
                
                // Or add by code
                VStack(alignment: .leading, spacing: 10) {
                    Text("Add by Username")
                        .font(.headline.weight(.semibold))
                        .foregroundStyle(theme.textPrimary)
                    
                    HStack(spacing: 10) {
                        UserInputField(userInput: $username)
                        
                        Button {
                            UIImpactFeedbackGenerator(style: .soft).impactOccurred()
                            performSearch()
                        } label: {
                            if isLoading {
                                ProgressView() // default spinning indicator
                                    .progressViewStyle(.circular)
                                    .tint(theme.textInverse)
                                    .frame(width: 20, height: 20)
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 10)
                            } else {
                                Text("Search")
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundStyle(theme.textInverse)
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 10)
                            }
                        }
                        .disabled(isLoading)
                        .buttonStyle(.plain)
                        .background(
                            RoundedRectangle(cornerRadius: theme.cornerRadiusSmall)
                                .fill(isLoading ? theme.primary.opacity(0.6) : theme.primary)
                        )
                        .animation(.easeInOut(duration: 0.2), value: isLoading)
                    }
                    
                    if hasSearched {
                        Group {
                            if isLoading {
                                
                                HStack {
                                    Spacer()
                                    ProgressView("Searching...")
                                        .tint(theme.primary)
                                        .padding(.top, 30)
                                    Spacer()
                                }
                                
                                
                            }
                            if searchResults.isEmpty {
                                UserNotFoundView()
                            }
                            else {
                                ScrollView {
                                    LazyVStack(spacing: 12) {
                                        ForEach(searchResults) { user in
                                            FriendRow(friend: user, onPressLabel: "Add") { friend in
                                            }
                                        }
                                    }
                                    .padding(.top, 10)
                                }
                            }
                        }.transition(.opacity.combined(with: .scale))
                            .animation(.easeInOut, value: isLoading)
                        
                    }
                }
                .padding(16)
                .background(theme.cardBackground)
                .clipShape(
                    RoundedRectangle(cornerRadius: theme.cornerRadiusLarge))
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
            
            await MainActor.run { isLoading = true } // start loading
            
            do {
                try await Task.sleep(nanoseconds: 1_000_000_000 ) // 2s
                
                
                let users: [User] = try await userController.searchUsers(byUsername: query)
                await MainActor.run {
                    hasSearched = true
                    searchResults = users.map { user in
                        Friend(username: user.username, stats: user.stats)
                    }
                    isLoading = false
                }
            } catch {
                print("❌ Search failed: \(error.localizedDescription)")
                await MainActor.run {
                    hasSearched = true
                    searchResults = []
                    isLoading = false
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
