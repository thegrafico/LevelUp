//
//  ToggleRow.swift
//  LevelUp
//
//  Created by Raúl Pichardo Avalo on 11/1/25.
//

import SwiftUI


struct ToggleRow: View {
    @Environment(\.theme) private var theme
    var icon: String
    var title: String
    @Binding var isOn: Bool
    
    var body: some View {
        HStack(spacing: 12) {
            IconBox(icon: icon, color: theme.primary)
            Text(title)
                .font(.body.weight(.semibold))
                .foregroundStyle(theme.textPrimary)
            Spacer()
            Toggle("", isOn: $isOn)
                .labelsHidden()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
}

#Preview {
    ToggleRow(icon: "plus", title: "Add new", isOn: .constant(true))
}
