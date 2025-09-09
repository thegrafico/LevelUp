//
//  Header.swift
//  LevelUp
//
//  Created by Raúl Pichardo Avalo on 9/8/25.
//

import SwiftUI



struct Header: View {
    
    var body: some View {
        ZStack(alignment: .top) {
            TopBannerBackground()
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
