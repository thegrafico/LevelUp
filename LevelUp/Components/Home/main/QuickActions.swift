//
//  QuickActions.swift
//  LevelUp
//
//  Created by Raúl Pichardo Avalo on 9/6/25.
//
import SwiftUI

// MARK: - Middle Hub (Quick Actions + Today’s Progress)
struct MiddleHubSection: View {
    @State private var showQuickActions = false

    var body: some View {
        HStack(spacing: 12) {
            // LEFT: Quick Actions (tappable)
            Button {
                let h = UIImpactFeedbackGenerator(style: .soft); h.impactOccurred()
                showQuickActions = true
            } label: {
                VStack(alignment: .leading, spacing: 6) {
                    HStack(spacing: 8) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(.orange)
                        Text("Quick Actions")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(.primary)
                    }
                    Text("Streak 5 days")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .buttonStyle(.plain)

            // VERTICAL DIVIDER
            Rectangle()
                .fill(Color.black.opacity(0.12))
                .frame(width: 1, height: 36)
                .cornerRadius(0.5)

            // RIGHT: Today's Progress (mini bar)
            VStack(alignment: .leading, spacing: 6) {
                Text("Today’s Progress")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.primary)

                ProgressView(value: 0.42) { EmptyView() }
                    .progressViewStyle(ThickLinearProgressStyle(height: 8))
                    .frame(maxWidth: .infinity)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .shadow(color: .black.opacity(0.06), radius: 8, y: 4)
        .shadow(color: .black.opacity(0.12), radius: 16, y: 10)
        .sheet(isPresented: $showQuickActions) {
            QuickActionsSheet()
                .presentationDetents([.medium, .large])
        }
    }
}

// MARK: - Quick Actions Sheet (modal)
struct QuickActionsSheet: View {
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
            .background(Color(.systemGroupedBackground))
        }
    }
}

struct ActionTile: View {
    var icon: String
    var title: String

    var body: some View {
        Button {
            let h = UIImpactFeedbackGenerator(style: .soft); h.impactOccurred()
        } label: {
            HStack(spacing: 10) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(Color.orange.opacity(0.12))
                        .frame(width: 40, height: 40)
                    Image(systemName: icon)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(.orange)
                }
                Text(title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.primary)
                Spacer(minLength: 0)
            }
            .padding(12)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            .shadow(color: .black.opacity(0.05), radius: 6, y: 3)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Big Complete Button
struct CompleteButton: View {
    var title: String = "COMPLETE"
    var action: () -> Void = {
        let h = UIImpactFeedbackGenerator(style: .heavy); h.impactOccurred()
    }

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.headline.weight(.heavy))
                .kerning(1)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 18)
                .background(
                    LinearGradient(colors: [.orange, .orange.opacity(0.85)],
                                   startPoint: .topLeading, endPoint: .bottomTrailing)
                )
                .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
                .shadow(color: .black.opacity(0.12), radius: 10, y: 8)
        }
        .buttonStyle(.plain)
    }
}
#Preview {
    MiddleHubSection()
    CompleteButton()
}
