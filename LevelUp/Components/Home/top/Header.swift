//
//  Header.swift
//  LevelUp
//
//  Created by Raúl Pichardo Avalo on 9/8/25.
//

import SwiftUI


struct Header: View {
    @Environment(\.currentUser) private var user
    @State private var showProfileSheet = false

    var body: some View {
        ZStack(alignment: .top) {
            TopBannerBackground()
                .ignoresSafeArea(edges: .top)

            VStack(spacing: 0) {
                BannerTitle(username: user.username)

                UserLevelXPCard(stats: user.stats) {
                    showProfileSheet = true
                }
            }
            .padding(.horizontal, 12)
        }
        .sheet(isPresented: $showProfileSheet) {
            PlayerProfileSheet() 
            .presentationDetents([.large])
        }
    }
}

#Preview {
    Header()
        .environment(\.currentUser, User.sampleUser())

}
