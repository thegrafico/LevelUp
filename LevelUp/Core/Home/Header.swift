//
//  Header.swift
//  LevelUp
//
//  Created by Raúl Pichardo Avalo on 9/8/25.
//

import SwiftUI



struct Header: View {
    
    private let bannerH: CGFloat = 220
    private let bannerCorner: CGFloat = 60
    
    var body: some View {
        ZStack(alignment: .top) {
            TopBannerBackground(
                height: bannerH,
                radius: bannerCorner
            )
                .ignoresSafeArea(edges: .top)

            VStack(spacing: 0) {
                BannerTitle()
                UserLevelXPCard()
            }
            .padding(.horizontal, 12)
        }
    }
}

#Preview {
    Header()
}
