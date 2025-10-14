//
//  ConnectToSocialView.swift
//  LevelUp
//
//  Created by Raúl Pichardo Avalo on 10/13/25.
//

import SwiftUI

struct ConnectToSocialView: View {
    @Environment(\.theme) private var theme

    var body: some View {
        Button {
            // TODO: integrate FB SDK or Contacts
        } label: {
            HStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: theme.cornerRadiusSmall)
                        .fill(theme.primary.opacity(0.12))
                        .frame(width: 40, height: 40)
                    Image(systemName: "f.cursive.circle.fill")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundStyle(theme.primary)
                }
                VStack(alignment: .leading, spacing: 2) {
                    Text("Connect Facebook")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(theme.textPrimary)
                    Text("Find friends from your contacts")
                        .font(.footnote)
                        .foregroundStyle(theme.textSecondary)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundStyle(theme.textSecondary)
            }
            .padding(14)
            .background(theme.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: theme.cornerRadiusLarge))
            .shadow(color: theme.shadowLight, radius: 6, y: 3)
        }
        .buttonStyle(.plain)
        .padding(.horizontal, 16)
        
    }
}

#Preview {
    ConnectToSocialView()
}
