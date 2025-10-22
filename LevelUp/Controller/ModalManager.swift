//
//  ConfirmationModal.swift
//  LevelUp
//
//  Created by Raúl Pichardo Avalo on 10/21/25.
//

import Foundation


struct ConfirmationModalData: Identifiable, Equatable {
    let id = UUID()
    let title: String
    let message: String?
    let confirmButtonTitle: String
    let cancelButtonTitle: String
    let confirmAction: () async throws -> Void
    
    static func == (lhs: ConfirmationModalData, rhs: ConfirmationModalData) -> Bool {
        lhs.id == rhs.id
    }
}

@MainActor
final class ModalManager: ObservableObject {
    @Published var activeModal: ConfirmationModalData? = nil

    func presentModal(_ modalData: ConfirmationModalData) {
        activeModal = modalData
    }

    func dismissModal() {
        activeModal = nil
    }
}
