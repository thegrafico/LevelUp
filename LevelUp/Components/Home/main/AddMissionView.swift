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

struct AddMissionView: View {
    @Environment(\.theme) private var theme
    @Environment(\.modelContext) private var context
    
    var onSave: (Mission) -> Void
    var onCancel: () -> Void

    // Draft Mission that will be saved if user confirms
    @State private var newMission = Mission(title: "", xp: 5, icon: Mission.availableIcons.first!)

    
    init(
        onSave: @escaping (Mission) -> Void = { _ in },
        onCancel: @escaping () -> Void = {}
    ) {
        self.onSave = onSave
        self.onCancel = onCancel
    }
    
    
    var body: some View {
        NavigationStack {
            Form {
                
                // MARK: Title
                Section("Mission Info") {
                    TextField("Title", text: $newMission.title)
                        .textInputAutocapitalization(.words)
                }
                
                // MARK: XP
                XPRewardPicker(selectedXP: $newMission.xp)
                
                // MARK: ICON
                IconPicker(selectedIcon: $newMission.icon)
                
                // MARK: Reminder
                ReminderSection(reminderDate: $newMission.reminderDate)
                
            }
            .navigationTitle("New Mission")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        onCancel()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                       onSave(newMission)
                   }.disabled(newMission.title.isEmpty)
                }
            }
        }
    }
}

#Preview {
    AddMissionView()
        .environment(\.theme, .orange)
}
