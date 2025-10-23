//
//  FriendRow.swift
//  LevelUp
//
//  Created by Raúl Pichardo Avalo on 10/11/25.
//

import SwiftUI

struct ShakeEffect: GeometryEffect {
    var travelDistance: CGFloat = 8
    var shakesPerUnit: CGFloat = 3
    var animatableData: CGFloat

    func effectValue(size: CGSize) -> ProjectionTransform {
        ProjectionTransform(
            CGAffineTransform(translationX:
                travelDistance * sin(animatableData * .pi * shakesPerUnit),
                y: 0)
        )
    }
}

extension View {
    func shake(trigger: CGFloat) -> some View {
        self.modifier(ShakeEffect(animatableData: trigger))
    }
}

struct FriendRow: View {
    @Environment(\.theme) private var theme
    var friend: Friend
    var onPressLabel: String = "Challenge"
    var updateLabelOnComplete: Bool = false
    var onPress: ((Friend) async throws -> Void)? = nil
    
    @State private var isLoading = false
    @State private var isSent = false
    @State private var errorMessage: String?
    @State private var shakeTrigger: CGFloat = 0  // 👈 Shake trigger

    var body: some View {
        VStack(spacing: 8) {
            HStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: theme.cornerRadiusSmall, style: .continuous)
                        .fill(friend.stats.isOnline ? theme.primary.opacity(0.18) : theme.textPrimary.opacity(0.08))
                        .frame(width: 48, height: 48)
                    Image(systemName: friend.avatar)
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundStyle(friend.stats.isOnline ? theme.primary : theme.textSecondary)
                }

                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 6) {
                        Text(friend.username)
                            .font(.headline.weight(.semibold))
                            .foregroundStyle(theme.textPrimary)
                        if friend.stats.isOnline {
                            Circle().fill(theme.primary).frame(width: 6, height: 6)
                        }
                    }
                    Text("Level \(friend.stats.level)")
                        .font(.subheadline)
                        .foregroundStyle(theme.textSecondary)
                }

                Spacer()

                Button {
                    Task { await sendRequest() }
                } label: {
                    if isLoading {
                        ProgressView()
                            .progressViewStyle(.circular)
                            .tint(theme.primary)
                            .frame(width: 16, height: 16)
                    } else if isSent && updateLabelOnComplete {
                        
                        Text("Sent ✓")
                            .font(.footnote.weight(.semibold))
                            .foregroundStyle(theme.textSecondary)
                    } else {
                        Text(onPressLabel)
                            .font(.footnote.weight(.semibold))
                            .foregroundStyle(theme.primary)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 8)
                            .background(Capsule().fill(theme.primary.opacity(0.1)))
                    }
                }
                .buttonStyle(.plain)
                .disabled(isLoading || (isSent && updateLabelOnComplete))
            }
            .padding(12)
            .background(theme.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: theme.cornerRadiusLarge, style: .continuous))
            .shadow(color: theme.shadowLight, radius: 6, y: 3)
            .shake(trigger: shakeTrigger) // 👈 Apply shake effect

            if let error = errorMessage {
                Text(error)
                    .font(.footnote)
                    .foregroundColor(.red)
                    .multilineTextAlignment(.center)
                    .transition(.opacity)
                    .animation(.easeInOut, value: errorMessage)
            }
        }
    }

    private func sendRequest() async {
        guard let onPress else { return }
        isLoading = true
        errorMessage = nil
        do {
            try await onPress(friend)
            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                isSent = true
            }
        } catch {
            // Animate shake
            withAnimation(.default) {
                shakeTrigger += 1  // 👈 triggers shake
                errorMessage = error.localizedDescription
            }
        }
        isLoading = false
    }
}

#Preview {
    FriendRow(friend: .init(username: "Thegrafico", stats: .init(level: 20, bestStreakCount: 10, topMission: "Drink Water", challengeWonCount: 20)))
}
