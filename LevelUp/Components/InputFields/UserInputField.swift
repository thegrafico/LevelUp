//
//  UserInputField.swift
//  LevelUp
//
//  Created by Raúl Pichardo Avalo on 10/13/25.
//

import SwiftUI

struct UserInputField: View {
    @Environment(\.theme) private var theme
    @Binding var userInput: String
    var body: some View {
        TextField("e.g., thegrafico", text: $userInput)
            .textInputAutocapitalization(.never)
            .disableAutocorrection(true)
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(theme.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: theme.cornerRadiusSmall))
            .overlay(
                RoundedRectangle(cornerRadius: theme.cornerRadiusSmall)
                    .stroke(theme.textPrimary.opacity(0.08), lineWidth: 1)
            )
    }
}

#Preview {
    UserInputField(userInput: .constant(""))
}
