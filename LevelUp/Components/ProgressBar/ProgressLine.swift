//
//  ProgressLine.swift
//  LevelUp
//
//  Created by Raúl Pichardo Avalo on 9/6/25.
//

import Foundation
import SwiftUI

struct ThickLinearProgressStyle: ProgressViewStyle {
    @Environment(\.theme) private var theme
    var height: CGFloat = 22

    func makeBody(configuration: Configuration) -> some View {
        GeometryReader { geo in
            let f = CGFloat(configuration.fractionCompleted ?? 0)
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: height/2, style: .continuous)
                    .fill(theme.textPrimary.opacity(0.10)) // track
                RoundedRectangle(cornerRadius: height/2, style: .continuous)
                    .fill(LinearGradient(colors: [theme.accent, theme.primary],
                                         startPoint: .leading, endPoint: .trailing))
                    .frame(width: geo.size.width * f)
            }
        }
        .frame(height: height)
    }
}
