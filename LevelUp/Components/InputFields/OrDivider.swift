//
//  OrDivider.swift
//  LevelUp
//
//  Created by Raúl Pichardo Avalo on 9/10/25.
//

import SwiftUI

struct OrDivider: View {
    @Environment(\.theme) private var theme
    var body: some View {
        HStack {
            Rectangle().fill(theme.textPrimary.opacity(0.08)).frame(height: 1)
            Text("OR")
                .font(.caption.weight(.semibold))
                .foregroundStyle(theme.textSecondary)
                .padding(.horizontal, 8)
            Rectangle().fill(theme.textPrimary.opacity(0.08)).frame(height: 1)
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    OrDivider()
}
