//
//  HomeHeaderCard.swift
//  LevelUp
//
//  Created by Raúl Pichardo Avalo on 9/6/25.
//

import SwiftUI



struct TopBannerBackground: View {
    var height: CGFloat = 220
    var radius: CGFloat = 120

    var body: some View {
        LinearGradient(
            colors: [
                Color(red: 0.78, green: 0.40, blue: 0.16), // warm orange
                Color(red: 0.55, green: 0.27, blue: 0.10)  // deep brown
            ],
            startPoint: .topLeading, endPoint: .bottomTrailing
        )
        .overlay( // subtle highlight
            LinearGradient(colors: [.white.opacity(0.12), .clear],
                           startPoint: .top, endPoint: .bottom)
        )
        .frame(maxWidth: .infinity, minHeight: height, maxHeight: height)
        .mask(
            UnevenRoundedRectangle(
                topLeadingRadius: 0,
                bottomLeadingRadius: radius,
                bottomTrailingRadius: radius,
                topTrailingRadius: 0,
                
                
                
                
                style: .continuous
            )
        )
        .shadow(color: .black.opacity(0.12), radius: 16, y: 8)
    }
}
#Preview {
    TopBannerBackground()
}
