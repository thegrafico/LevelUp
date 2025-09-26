//
//  ReminderSelection.swift
//  LevelUp
//
//  Created by Raúl Pichardo Avalo on 9/26/25.
//

import SwiftUI

struct ReminderSection: View {
    @Environment(\.theme) private var theme
    
    @Binding var reminderDate: Date?
    
    var body: some View {
        Section("Reminder") {
            Toggle("Set Reminder", isOn: Binding(
                get: { reminderDate != nil },
                set: { enabled in
                    reminderDate = enabled ? Date() : nil
                }
            ))
            
            if let date = reminderDate {
                DatePicker(
                    "Time",
                    selection: Binding(
                        get: { date },
                        set: { reminderDate = $0 }
                    ),
                    displayedComponents: .hourAndMinute
                )
                .datePickerStyle(.compact)
            }
        }
    }
}

#Preview {
    ReminderSection(reminderDate: .constant(.now))
}
