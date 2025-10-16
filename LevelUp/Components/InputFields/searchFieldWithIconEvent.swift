//
//  searchFieldWithIconEvent.swift
//  LevelUp
//
//  Created by Raúl Pichardo Avalo on 10/15/25.
//

import SwiftUI

struct searchFieldWithIconEvent: View {
    @Environment(\.theme) private var theme
    
    @Binding var userQuery: String
    @Binding var toggleSheet: Bool

    var body: some View {
        // Search
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass").foregroundStyle(theme.textSecondary)
            TextField("Search friends", text: $userQuery)
                .textInputAutocapitalization(.never)
                .disableAutocorrection(true)
            
            Button { toggleSheet.toggle() } label: {
                Label("Add", systemImage: "person.badge.plus")
                    .labelStyle(.iconOnly)
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(theme.primary)
                    .padding(10)
                    .background(
                        RoundedRectangle(cornerRadius: theme.cornerRadiusSmall)
                            .fill(theme.primary.opacity(0.12))
                    )
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(theme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: theme.cornerRadiusLarge, style: .continuous))
        .shadow(color: theme.shadowLight, radius: 6, y: 3)
        .padding(.horizontal, 20)
    }
}

#Preview {
    searchFieldWithIconEvent(userQuery: .constant(""), toggleSheet: .constant(false))
        .environment(\.theme, .orange)

}
