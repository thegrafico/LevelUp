//
//  ReminderSelection.swift
//  LevelUp
//
//  Created by Raúl Pichardo Avalo on 9/26/25.
//

import SwiftUI

enum ReminderStyle {
    case form, inline
}

struct ReminderSection: View {
    @Environment(\.theme) private var theme
    
    @Binding var reminder: Reminder
    var style: ReminderStyle = .form

    
    var body: some View {
        
        Group {
            if style == .form {
                Section("Reminder") {
                    ReminderContent
                }
            } else {
                VStack(alignment: .leading, spacing: 10) {
                    // 🏷 Title (no background)
                    Text("Reminder")
                        .shadow(color: .black.opacity(0.4), radius: 5, y: 3)
                        .font(.headline.weight(.bold))
                        .fontDesign(.rounded)
                        .foregroundStyle(theme.textPrimary)
                        .textCase(.uppercase)
                        .padding(.bottom, 4)

                    // 🧱 Editable content (with background)
                    VStack {
                        ReminderContent
                            .padding(.vertical, 10)
                            .padding(.horizontal, 14)
                    }
                    .background(
                        RoundedRectangle(cornerRadius: 14)
                            .fill(theme.cardBackground.opacity(0.95))
                            .overlay(
                                RoundedRectangle(cornerRadius: 14)
                                    .stroke(theme.accent.opacity(0.2), lineWidth: 1)
                            )
                    )
                    .shadow(color: .black.opacity(0.25), radius: 4, y: 2)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
            }
        }
    }
    
    private var ReminderContent: some View {
        VStack(alignment: .leading, spacing: 10) {
            Toggle("Set Reminder", isOn: Binding(
                get: { reminder.isEnabled },
                set: { newValue in
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                        reminder.isEnabled = newValue
                    }
                }
            ))

            if reminder.isEnabled {
                VStack(alignment: .leading, spacing: 12) {
                    // 🕓 Time picker
                    DatePicker(
                        "Time",
                        selection: $reminder.time,
                        displayedComponents: .hourAndMinute
                    )
                    .datePickerStyle(.compact)
                    
                    Toggle("Repeat every week", isOn: $reminder.repeatsWeekly)
                           .tint(theme.primary) // optional
                    // 📅 Repeat days picker
                    VStack(alignment: .leading, spacing: 6) {
                        HStack(spacing: 8) {
                            ForEach(QuickRepeatPreset.allCases) { preset in
                                PresetChip(
                                    title: preset.rawValue,
                                    isSelected: reminder.repeatDays == preset.days()
                                ) {
                                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                        reminder.repeatDays = preset.days()
                                    }
                                }
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.horizontal, 8)
                        .padding(.bottom, 4)

                        let columns = Array(repeating: GridItem(.flexible(), spacing: 8), count: 7)

                        LazyVGrid(columns: columns, spacing: 8) {
                            ForEach(Weekday.allCases, id: \.self) { day in
                                DayChip(
                                    day: day,
                                    isSelected: (reminder.repeatDays.contains(day))
                                ) {
                                    toggleDay(day)
                                    
                                    if reminder.repeatDays.isEmpty {
                                        toggleDay(Weekday.today)
                                    }
                                    print(reminder.repeatDays.count)
                                }
                            }
                        }
                        .padding(.vertical, 6)
                        .padding(.horizontal, 16)
                        
                        
                        HStack (alignment: .center) {
                            Spacer()
                            Text(reminder.descriptionText)
                                .font(.caption)
                            Spacer()
                        }
                        
                    }
                    .padding(.vertical, 12)
                }
                .onAppear {
                    if reminder.repeatDays.isEmpty {
                        toggleDay(Weekday.today)
                    }
                }
                .transition(.asymmetric(
                    insertion: .move(edge: .top)
                        .combined(with: .opacity)
                        .combined(with: .scale(scale: 0.98)),
                    removal: .opacity.combined(with: .scale(scale: 0.9))
                ))
            }
        }
    }
    
    private func toggleDay(_ day: Weekday) {
        if reminder.repeatDays.contains(day) {
            reminder.repeatDays.remove(day)
        } else {
            reminder.repeatDays.insert(day)
        }
    }
    
    struct PresetChip: View {
        @Environment(\.theme) private var theme

        var title: String
        var isSelected: Bool
        var onTap: () -> Void

        var body: some View {
            Text(title)
                .font(.footnote.weight(.semibold))
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(isSelected ? theme.primary : theme.cardBackground)
                )
                .foregroundStyle(isSelected ? theme.textInverse : theme.textPrimary.opacity(0.8))
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(theme.accent.opacity(0.2), lineWidth: 1)
                )
                .onTapGesture {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        onTap()
                    }
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                }
        }
    }
}

enum QuickRepeatPreset: String, CaseIterable, Identifiable {
    case everyDay = "Every Day"
    case weekdays = "Weekdays"
    case weekends = "Weekends"

    var id: String { rawValue }

    func days() -> Set<Weekday> {
        switch self {
        case .everyDay: return Set(Weekday.allCases)
        case .weekdays: return Set(Weekday.allCases.filter { !$0.isWeekend })
        case .weekends: return Set(Weekday.allCases.filter { $0.isWeekend })
        }
    }
}

struct DayChip: View {
    @Environment(\.theme) private var theme

    var day: Weekday
    var isSelected: Bool
    var onTap: () -> Void
    
    var body: some View {
        
        Text(day.shortName)
            .font(.subheadline.weight(.bold))
            .frame(width: 30, height: 30)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(isSelected ? theme.primary : theme.cardBackground)
            )
            .foregroundStyle(isSelected ? theme.textInverse : theme.textPrimary.opacity(0.8))
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(theme.accent.opacity(0.2), lineWidth: 1)
            )
            .onTapGesture {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    onTap()
                }
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
            }
        
    }
    
}
#Preview {
    PreviewWrapper()
}

private struct PreviewWrapper: View {
    @State private var reminder = Reminder(isEnabled: true)

    var body: some View {
        ReminderSection(reminder: $reminder)
            .padding()
            .background(Color(.systemBackground))
            .previewLayout(.sizeThatFits)
    }
}
