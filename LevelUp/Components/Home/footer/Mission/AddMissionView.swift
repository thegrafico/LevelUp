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
//import SwiftData

struct AddMissionView: View {
    @Environment(\.theme) private var theme
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context

    // Draft Mission that will be saved if user confirms
    @Bindable var mission: Mission /*Mission(title: "", xp: 5, icon: Mission.availableIcons.first!)*/
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
                        .textInputAutocapitalization(.words)
                }
                
                // MARK: XP
                XPRewardPicker(selectedXP: $mission.xp)
                
                // MARK: ICON
                IconPicker(selectedIcon: $mission.icon)
                
                // MARK: Reminder
                ReminderSection(reminderDate: $mission.reminderDate)
                
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
                        
                        if isNew {
                            context.insert(mission)
                        }
                        onSave(mission)
                        dismiss()
                   }.disabled(mission.title.isEmpty)
                }
            }
        }
    }
}

#Preview {
    AddMissionView(mission: .init(title: "New Mission", xp: 5, icon: Mission.availableIcons.first!), isNew: false)
        .environment(\.theme, .orange)
}
