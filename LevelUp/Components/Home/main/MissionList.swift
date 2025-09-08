//
//  MissionList.swift
//  LevelUp
//
//  Created by Raúl Pichardo Avalo on 9/6/25.
//
import SwiftUI

// MARK: - Section
struct MissionList: View {

    @State private var items: [Mission] = Mission.sampleData

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Daily Missions")
                .font(.title3.weight(.bold))
                .padding(.horizontal, 20)

            ScrollView {

                VStack(spacing: 16) {
                    ForEach(items.indices, id: \.self) { i in
                        MissionRow(mission: items[i], onToggle: { _ in })
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
        }
    }
}

// MARK: - Preview (UI-only)
#Preview {
    ScrollView {
        VStack(spacing: 16) {
            MissionList()
        }
        .padding(.vertical, 20)
    }
}
