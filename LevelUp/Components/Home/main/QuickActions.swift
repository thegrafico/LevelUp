//
//  QuickActions.swift
//  LevelUp
//
//  Created by Raúl Pichardo Avalo on 9/6/25.
//
import SwiftUI

// MARK: - Middle Hub (Quick Actions + Today’s Progress)
struct MiddleHubSection: View {
    @Environment(\.theme) private var theme
    @State private var showQuickActions = false

    var body: some View {
        HStack(spacing: 12) {
            // LEFT: Quick Actions (tappable)
            Button {
                UIImpactFeedbackGenerator(style: .soft).impactOccurred()
                showQuickActions = true
            } label: {
                VStack(alignment: .leading, spacing: 6) {
                    HStack(spacing: 8) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(theme.primary)
                        Text("Quick Actions")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(theme.textPrimary)
                    }
                    Text("Streak 5 days")
                        .font(.footnote)
                        .foregroundStyle(theme.textSecondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .buttonStyle(.plain)

            // VERTICAL DIVIDER
            Rectangle()
                .fill(theme.textPrimary.opacity(0.12))
                .frame(width: 1, height: 36)
                .cornerRadius(0.5)

            // RIGHT: Today's Progress (mini bar)
            VStack(alignment: .leading, spacing: 6) {
                Text("Today’s Progress")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(theme.textPrimary)

                ProgressView(value: 0.42) { EmptyView() }
                    .progressViewStyle(ThickLinearProgressStyle(height: 8)) // themed style
                    .frame(maxWidth: .infinity)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
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
        .padding(.horizontal, 30)
        .padding(.bottom, 12)
    }
}

// MARK: - Quick Actions Sheet (modal)
struct QuickActionsSheet: View {
    @Environment(\.theme) private var theme
    private let columns = [GridItem(.adaptive(minimum: 120), spacing: 12, alignment: .top)]

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 12) {
                    ActionTile(icon: "plus.circle.fill", title: "New Mission")
                    ActionTile(icon: "figure.run",       title: "Start Run")
                    ActionTile(icon: "dumbbell.fill",    title: "Gym")
                    ActionTile(icon: "book.fill",        title: "Read")
                    ActionTile(icon: "mappin.and.ellipse", title: "Visit Place")
                    ActionTile(icon: "bell.badge.fill",  title: "Reminders")
                }
                .padding(16)
            }
            .navigationTitle("Quick Actions")
            .navigationBarTitleDisplayMode(.inline)
            .background(theme.background)
        }
    }
}

struct ActionTile: View {
    @Environment(\.theme) private var theme
    var icon: String
    var title: String

    var body: some View {
        Button {
            UIImpactFeedbackGenerator(style: .soft).impactOccurred()
        } label: {
            HStack(spacing: 10) {
                ZStack {
                    RoundedRectangle(cornerRadius: theme.cornerRadiusSmall, style: .continuous)
                        .fill(theme.primary.opacity(0.12))
                        .frame(width: 40, height: 40)
                    Image(systemName: icon)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(theme.primary)
                }
                Text(title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(theme.textPrimary)
                Spacer(minLength: 0)
            }
            .padding(12)
            .background(theme.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: theme.cornerRadiusSmall, style: .continuous))
            .shadow(color: theme.shadowLight, radius: 6, y: 3)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Big Complete Button
struct CompleteButton: View {
    @Environment(\.theme) private var theme
    var title: String = "COMPLETE"
    var action: () -> Void = {
        UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
    }

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.headline.weight(.heavy))
                .kerning(1)
                .foregroundStyle(theme.textInverse)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 18)
                .background(
                    LinearGradient(colors: [theme.primary, theme.primary.opacity(0.85)],
                                   startPoint: .topLeading, endPoint: .bottomTrailing)
                )
                .clipShape(RoundedRectangle(cornerRadius: theme.cornerRadiusLarge, style: .continuous))
                .shadow(color: theme.shadowDark, radius: 10, y: 8)
        }
        .buttonStyle(.plain)
        .padding(.horizontal, 20)
        .padding(.top, 12)
    }
}
#Preview {
    MiddleHubSection()
        .environment(\.theme, .blue)
    CompleteButton()
        .environment(\.theme, .blue)
}
