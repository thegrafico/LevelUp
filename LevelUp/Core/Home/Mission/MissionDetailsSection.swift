//
//  MissionDetailsSection.swift
//  LevelUp
//
//  Created by Raúl Pichardo Avalo on 10/26/25.
//

import SwiftUI

struct MissionDetailsSection: View {
    @Environment(\.theme) private var theme
    @Binding var details: String
    
    var body: some View {
        Section("Details") {
            ZStack(alignment: .topLeading) {
                // Placeholder
                if details.isEmpty {
                    Text("Describe what this mission is about...")
                        .font(.callout)
                        .foregroundStyle(theme.textSecondary.opacity(0.6))
                        .padding(.vertical, 8)
                        .padding(.horizontal, 10)
                }

                // Simple, readable text area
                TextEditor(text: $details)
                    .font(.callout)
                    .foregroundStyle(theme.textPrimary)
                    .scrollContentBackground(.hidden)
                    .frame(height: 60)
                    .padding(6)
                    .background(
                        RoundedRectangle(cornerRadius: theme.cornerRadiusMedium)
                            .fill(theme.cardBackground)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: theme.cornerRadiusMedium))
                    .shadow(color: .black.opacity(0.08), radius: 3, y: 2)
                    .autocorrectionDisabled(true)
            }
        }
    }
}

#Preview {
    MissionDetailsSection(details: .constant(""))
        .environment(\.theme, .orange)
}
