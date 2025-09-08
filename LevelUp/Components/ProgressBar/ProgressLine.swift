//
//  ProgressLine.swift
//  LevelUp
//
//  Created by Raúl Pichardo Avalo on 9/6/25.
//

import Foundation
import SwiftUI

struct ThickLinearProgressStyle: ProgressViewStyle {
    var height: CGFloat = 20
    var trackColor: Color = .black.opacity(0.08)
    var fill: LinearGradient = .init(colors: [.yellow, .orange],
                                     startPoint: .leading, endPoint: .trailing)
    var corner: CGFloat? = nil  // nil = height/2 (cápsula)

    func makeBody(configuration: Configuration) -> some View {
        GeometryReader { geo in
            let progress = CGFloat(configuration.fractionCompleted ?? 0)
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: corner ?? height/2, style: .continuous)
                    .fill(trackColor)
                RoundedRectangle(cornerRadius: corner ?? height/2, style: .continuous)
                    .fill(fill)
                    .frame(width: max(0, geo.size.width * progress))
            }
        }
        .frame(height: height)
    }
}
