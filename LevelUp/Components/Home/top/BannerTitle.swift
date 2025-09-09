//
//  BannerTitle.swift
//  LevelUp
//
//  Created by Raúl Pichardo Avalo on 9/6/25.
//

import SwiftUI

struct BannerTitle: View {
    @Environment(\.theme) private var theme

    var body: some View {
        HStack {
            
            Image(systemName: "person.circle")
                .resizable()
                .frame(width: 64, height: 64)
                .fontWeight(.bold)
            
            Text("LEVEL UP")
                .font(.system(size: 42, weight: .black, design: .rounded))
                .kerning(2)
                
            
            Spacer()
        }
        .padding(.horizontal, 20)
        .foregroundStyle(theme.textInverse)
    }
}

#Preview {
    BannerTitle()
        .padding(20)
        .background(Color.black)
    
}
