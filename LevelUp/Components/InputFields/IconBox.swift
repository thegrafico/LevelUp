//
//  IconBox.swift
//  LevelUp
//
//  Created by Raúl Pichardo Avalo on 11/1/25.
//

import SwiftUI

struct IconBox: View {
    var icon: String
    var color: Color
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(color.opacity(0.12))
                .frame(width: 36, height: 36)
            Image(systemName: icon)
                .foregroundStyle(color)
                .font(.system(size: 16, weight: .semibold))
        }
    }
}

#Preview {
    IconBox(icon: "plus", color: Color.red)
}
