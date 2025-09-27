//
//  MissionSortMenu.swift
//  LevelUp
//
//  Created by Raúl Pichardo Avalo on 9/26/25.
//

import SwiftUI

struct MissionSortMenu: View {
    @Binding var selectedSort: MissionSort
    @Environment(\.theme) private var theme

    var body: some View {
        Menu {
            ForEach(MissionSort.allCases) { sort in
                Button {
                    selectedSort = sort
                } label: {
                    HStack {
                        Text(sort.rawValue)
                        if selectedSort == sort {
                            Image(systemName: "checkmark")
                        }
                    }
                }
            }
        } label: {
            Label("Sort", systemImage: "arrow.up.arrow.down")
                .labelStyle(.iconOnly)
                .font(.title3)
                .foregroundStyle(theme.primary)
        }
    }
}

#Preview {
    MissionSortMenu(selectedSort: .constant(MissionSort.name))
}
