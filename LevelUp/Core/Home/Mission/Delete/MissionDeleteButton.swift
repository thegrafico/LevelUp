//
//  MissionDeleteButton.swift
//  LevelUp
//
//  Created by Raúl Pichardo Avalo on 10/23/25.
//

import SwiftUI

struct MissionDeleteButton: View {
    @Environment(\.theme) private var theme
    @EnvironmentObject private var modalManager: ModalManager

    var selectedMissions: [Mission]
    var onConfirmDelete: () -> Void

    var body: some View {
        Button {
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.impactOccurred()

            modalManager.presentModal(
                ConfirmationModalData(
                    title: "Delete Selected Missions?",
                    message: "You are about to delete \(selectedMissions.count) mission(s). This action cannot be undone.",
                    confirmButtonTitle: "Delete",
                    cancelButtonTitle: "Cancel",
                    confirmAction: {
                        withAnimation {
                            onConfirmDelete()
                        }
                    }
                )
            )
        } label: {
            Image(systemName: "trash.fill")
                .font(.title3)
                .symbolRenderingMode(.hierarchical)
                .foregroundStyle(theme.primary)
                .opacity(!selectedMissions.isEmpty ? 1 : 0.3)
                .symbolEffect(.bounce, value: !selectedMissions.isEmpty)
        }
        .disabled(selectedMissions.isEmpty)
        .transition(.asymmetric(
            insertion: .move(edge: .trailing).combined(with: .opacity),
            removal:  .scale(scale: 0.7).combined(with: .opacity)
        ))
    }
}

#Preview {
    MissionDeleteButton(selectedMissions: [Mission(title: "Running", xp: 15, icon: "plus")], onConfirmDelete: {})
}
