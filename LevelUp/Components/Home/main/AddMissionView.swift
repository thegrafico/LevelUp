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
    @Environment(\.dismiss) private var dismiss
    
    // UI-only
    @State private var title: String = ""
    @State private var selectedIcon: String = "star.fill"
    @State private var selectedXP: Int = 5
    @State private var reminderEnabled: Bool = false
    @State private var reminderDate: Date = Date()
    
    // Expanded icons (daily actions)
    private let availableIcons = [
        "figure.run", "dumbbell.fill", "book.fill", "brain.head.profile",
        "cup.and.saucer.fill", "drop.fill", "moon.fill", "sun.max.fill",
        "mappin.and.ellipse", "checkmark.circle.fill", "heart.fill", "star.fill"
    ]
    
    // Allowed XP values
    private let xpValues = [5, 10, 15, 20]
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Mission Info")) {
                    TextField("Title", text: $title)
                        .textInputAutocapitalization(.words)
                }
                
                Section(header: Text("XP Reward")) {
                    LazyVGrid(
                        columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 4), // 4 columns
                        spacing: 12
                    ) {
                        ForEach(xpValues, id: \.self) { value in
                            let isSelected = selectedXP == value
                            
                            Text("\(value)")
                                .font(.subheadline.weight(.semibold))
                                .frame(maxWidth: .infinity) // stretch inside grid cell
                                .padding(.vertical, 10)
                                .background(
                                    RoundedRectangle(cornerRadius: theme.cornerRadiusSmall, style: .continuous)
                                        .fill(isSelected ? theme.primary : theme.cardBackground)
                                )
                                .foregroundStyle(isSelected ? theme.textInverse : theme.textPrimary)
                                .overlay(
                                    RoundedRectangle(cornerRadius: theme.cornerRadiusSmall, style: .continuous)
                                        .stroke(theme.textSecondary.opacity(0.2), lineWidth: isSelected ? 0 : 1)
                                )
                                .onTapGesture { selectedXP = value }
                        }
                    }
                    .padding(.vertical, 4)
                }
                
                Section(header: Text("Icon")) {
                    ScrollView(.horizontal, showsIndicators: true) {
                        HStack(spacing: 16) {
                            ForEach(availableIcons, id: \.self) { icon in
                                Button {
                                    selectedIcon = icon
                                } label: {
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                                            .fill(selectedIcon == icon ? theme.primary.opacity(0.2) : theme.cardBackground)
                                            .frame(width: 50, height: 50)
                                        Image(systemName: icon)
                                            .foregroundStyle(theme.primary)
                                            .font(.system(size: 20, weight: .semibold))
                                    }
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.vertical, 8)
                    }
                }
                
                Section(header: Text("Reminder")) {
                    Toggle("Set Reminder", isOn: $reminderEnabled)
                    
                    if reminderEnabled {
                        DatePicker(
                            "Time",
                            selection: $reminderDate,
                            displayedComponents: .hourAndMinute
                        )
                        .datePickerStyle(.compact) // or .wheel for iOS
                    }
                }
            }
            .navigationTitle("New Mission")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        // later: save mission
                        dismiss()
                    }
                    .disabled(title.isEmpty)
                }
            }
        }
    }
}

#Preview {
    AddMissionView()
        .environment(\.theme, .orange)
}
