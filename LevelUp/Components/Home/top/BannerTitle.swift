//
//  BannerTitle.swift
//  LevelUp
//
//  Created by Raúl Pichardo Avalo on 9/6/25.
//

import SwiftUI

struct BannerTitle: View {
    @Environment(\.theme) private var theme
    
    var username: String
    var body: some View {
        HStack {
            
            Image(systemName: "person.circle")
                .resizable()
                .frame(width: 64, height: 64)
                .fontWeight(.bold)
            
            Text("\(username)")
                .font(.system(size: 24, weight: .black, design: .rounded))
                .kerning(2)
                .lineLimit(1)
                
            
            Spacer()
        }
        .padding(.horizontal, 20)
        .foregroundStyle(theme.textInverse)
    }
}

#Preview {
    BannerTitle(username: "TheMonsterIsHereas")
        .padding(20)
        .background(Color.black)
    
}
