//
//  ThemePicker.swift
//  LevelUp
//
//  Created by Raúl Pichardo Avalo on 11/1/25.
//

import SwiftUI

struct ThemePickerRow: View {
    @AppStorage("selectedTheme") private var selectedThemeRawValue: String = ThemeOption.system.rawValue
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.theme) private var theme
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Picker("Theme", selection: $selectedThemeRawValue) {
                ForEach(ThemeOption.allCases) { option in
                    HStack {
                        Circle()
                            .fill(option.resolve(using: colorScheme).primary)
                            .frame(width: 22, height: 22)
                        Text(option.displayName)
                    }
                    .tag(option.rawValue)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal, 16)
            // 👇 This forces a re-creation of the UIKit view with correct theme
            .id(theme.primary.description)
            .onAppear { updateSegmentedControlAppearance() }
            .onChange(of: theme.primary) {
                updateSegmentedControlAppearance()
            }
        }
    }
    
    func updateSegmentedControlAppearance() {
        let appearance = UISegmentedControl.appearance()
        appearance.selectedSegmentTintColor = UIColor(theme.primary)
        appearance.backgroundColor = UIColor(theme.cardBackground)
        appearance.setTitleTextAttributes(
            [.foregroundColor: UIColor(theme.textPrimary)],
            for: .normal
        )
        appearance.setTitleTextAttributes(
            [.foregroundColor: UIColor(theme.textInverse)],
            for: .selected
        )
    }
}

#Preview {
    NavigationStack {
        ThemePickerRow()
    }
    .modelContainer(SampleData.shared.modelContainer)
    .environment(\.theme, .dark)
    
}
