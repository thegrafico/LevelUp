//
//  BannerTitle.swift
//  LevelUp
//
//  Created by Raúl Pichardo Avalo on 9/6/25.
//

import SwiftUI

struct BannerTitle: View {
    var body: some View {
        HStack {
            
            Image(systemName: "person.circle")
                .resizable()
                .frame(width: 64, height: 64)
                .foregroundStyle(.yellow)
                .fontWeight(.bold)
            
            Text("LEVEL UP")
                .font(.system(size: 42, weight: .black, design: .rounded))
                .kerning(2)
                .foregroundStyle(
                    LinearGradient(
                        colors: [.yellow, .orange],
                        startPoint: .leading, endPoint: .trailing
                    )
                )   // solid color
            
            
            Spacer()
        }.padding(.horizontal, 20)
    }
}

#Preview {
    BannerTitle()
}
