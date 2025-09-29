//
//  QuickActions.swift
//  LevelUp
//
//  Created by Raúl Pichardo Avalo on 9/6/25.
//
import SwiftUI


struct QuickActionsView: View {
    
    @Binding var showActionsSheet: Bool
    @Environment(\.theme) private var theme
    
    var body: some View {
        Button {
            UIImpactFeedbackGenerator(style: .soft).impactOccurred()
            showActionsSheet = true
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
    }
}

// MARK: - Quick Actions Sheet (modal)
struct QuickActionsSheet: View {
    @Environment(\.theme) private var theme
    @Environment(\.dismiss) private var dismiss
    
    @State private var showAddMission = false
    @State private var newMission: Mission? = nil
    @State private var showPopup = false   // 👈 control variable
    
    private let columns = [GridItem(.adaptive(minimum: 120), spacing: 12, alignment: .top)]

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 12) {
                    ActionTile(icon: "plus.circle.fill", title: "New Mission") {
                        newMission = Mission(title: "", xp: Mission.xpValues.first!, icon: Mission.availableIcons.first!)
                        showAddMission.toggle()
                        self.showPopup = false
                    }
                    
                    Group {
                        ActionTile(icon: "figure.run",       title: "Start Run")
                        ActionTile(icon: "dumbbell.fill",    title: "Gym")
                        ActionTile(icon: "book.fill",        title: "Read")
                        ActionTile(icon: "mappin.and.ellipse", title: "Visit Place")
                        ActionTile(icon: "bell.badge.fill",  title: "Reminders")
                    }
                    .disabled(true)
                    
                }
                .padding(16)
            }
            .navigationTitle("Quick Actions")
            .navigationBarTitleDisplayMode(.inline)
            .background(theme.background)
        }
        .sheet(item: $newMission) { mission in
            AddMissionView(mission: mission, isNew: true, onSave: { _ in
                    self.showPopup.toggle()
            })
                .environment(\.theme, theme)
        }.overlay(
            
            Group {
                if showPopup {
                    FloatingPopup(duration: 3, text: "+1 Mission!")
                        .offset(y: -100)
                }
                
            },
            alignment: .centerLastTextBaseline
        )
        
    }
}

struct ActionTile: View {
    @Environment(\.theme) private var theme
    var icon: String
    var title: String
    var action: () -> Void = {}   // default no-op

    var body: some View {
        Button(action: {
            UIImpactFeedbackGenerator(style: .soft).impactOccurred()
            action()
        }) {
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


#Preview {
    MiddleHubSection()
        .environment(\.theme, .blue)
}
