//
//  AddMissionView.swift
//  LevelUp
//
//  Created by Raúl Pichardo Avalo on 9/9/25.
//
//
//  AddMissionView.swift
//  LevelUp
//
import SwiftUI
import SwiftData

struct AddMissionView: View {
    @Environment(\.theme) private var theme
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    @Environment(BadgeManager.self) private var badgeManager: BadgeManager?
    @Environment(\.currentUser) private var user
    @EnvironmentObject private var notificationManager: NotificationManager

    
    private var missionController: MissionController {
        MissionController(context: context, user: user, badgeManager: badgeManager, notificationManager: notificationManager)
    }
    
    @Bindable var mission: Mission
    
    var isNew: Bool
    var onSave: (_ mission: Mission) -> Void
    
    init(
        mission: Mission,
        isNew: Bool = false,
        onSave: @escaping (Mission) -> Void = { _ in },
       ) {
           self.mission = mission
           self.isNew = isNew
           self.onSave = onSave
       }
    
    var body: some View {
        NavigationStack {
            Form {
                
                // MARK: Title
                Section("Mission Info") {
                    TextField("Title", text: $mission.title)
                        .disableAutocorrection(true)
                }
                
                // MARK: XP
                XPRewardPicker(selectedXP: $mission.xp)
                
                // MARK: ICON
                IconPicker(selectedIcon: $mission.icon)
                
                // MARK: CATEGORY
                MissionCategoryPicker(selectedCategory: $mission.category)
                
                // MARK: Details
                MissionDetailsSection(details: Binding(
                   get: { mission.details ?? "" },
                   set: { mission.details = $0.isEmpty ? nil : $0 }
               ))
              
                // MARK: Reminder
                ReminderSection(reminder: $mission.reminder)
            }
            
            .navigationTitle(isNew ? "New Mission" : "Edit Mission")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(isNew ? "Add" : "Save" ) {
                        Task {
                            await saveMission()
                        }
                   }.disabled(mission.title.isEmpty)
                }
            }
        }
    }
    @MainActor
    private func saveMission() async {
        
        // MARK: Add the mission to swift Data
        if isNew {
            await missionController.insertMission(mission)
        }

        onSave(mission)
        dismiss()
    }
    
}

#Preview {
    AddMissionView(
        mission: .init(title: "New Mission", xp: 5, icon: Mission.availableIcons.first!),
        isNew: true
    )
    .environment(\.theme, .orange)
    .environment(BadgeManager()) // 👈 inject preview manager
    .environment(\.currentUser, User.sampleUserWithLogs())
    .environmentObject(NotificationManager())
}
