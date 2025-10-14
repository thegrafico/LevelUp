//
//  UserNotFoundView.swift
//  LevelUp
//
//  Created by Raúl Pichardo Avalo on 10/13/25.
//

import SwiftUI

struct UserNotFoundView: View {
    @Environment(\.theme) private var theme

    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Spacer()
                Image(systemName: "person.fill.questionmark")
                    .font(.largeTitle)
                    .foregroundStyle(theme.primary)
                Text("No users found")
                    .font(.headline)
                    .foregroundStyle(theme.textSecondary)
                Spacer()
            }
        }.padding(.top, 20)
    }
}



#Preview {
    UserNotFoundView()
}
