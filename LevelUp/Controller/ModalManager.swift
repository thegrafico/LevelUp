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
    let cancelAction: (() async throws -> Void)?   // ✅ remove “Void?” inside
    
    init(
        title: String,
        message: String? = nil,
        confirmButtonTitle: String,
        cancelButtonTitle: String,
        confirmAction: @escaping () async throws -> Void,
        cancelAction: (() async throws -> Void)? = nil  // ✅ optional param
    ) {
        self.title = title
        self.message = message
        self.confirmButtonTitle = confirmButtonTitle
        self.cancelButtonTitle = cancelButtonTitle
        self.confirmAction = confirmAction
        self.cancelAction = cancelAction
    }
    
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
