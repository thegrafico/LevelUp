//
//  IconPicker.swift
//  LevelUp
//
//  Created by Raúl Pichardo Avalo on 9/26/25.
//

import SwiftUI

struct IconPicker: View {
    @Environment(\.theme) private var theme
    @Binding var selectedIcon: String
    
    var body: some View {
        Section("Icon") {
            ScrollViewReader { proxy in
                ScrollView(.horizontal, showsIndicators: true) {
                    HStack(spacing: 16) {
                        ForEach(Mission.availableIcons, id: \.self) { icon in
                            Button {
                                withAnimation {
                                    selectedIcon = icon
                                    proxy.scrollTo(icon, anchor: .center)
                                }
                            } label: {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                                        .fill(selectedIcon == icon ? theme.primary.opacity(0.2) : theme.cardBackground)
                                        .frame(width: 50, height: 50)
                                    Image(systemName: icon)
                                        .foregroundStyle(theme.primary)
                                        .font(.system(size: 20, weight: .semibold))
                                }
                            }
                            .id(icon) // 👈 important for scrollTo
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.vertical, 8)
                }
                .onAppear {
                    // scroll to the current selection when view loads
                    if let _ = Mission.availableIcons.firstIndex(of: selectedIcon) {
                        proxy.scrollTo(selectedIcon, anchor: .center)
                    }
                }
            }
        }
    }
}

#Preview {
    IconPicker(selectedIcon: .constant(Mission.availableIcons.first!))
}
