//
//  AboutView.swift
//  LevelUp
//
//  Created by Raúl Pichardo Avalo on 11/1/25.
//

import SwiftUI

struct AboutView: View {
    @Environment(\.theme) private var theme

    var body: some View {
        
        ZStack {
            theme.background
                .ignoresSafeArea()
            ScrollView {
                
                XPAppIcon(size: 150)
                    .padding(.top, 20)
                
                VStack(spacing: 20) {
                    Text("LevelUp")
                        .font(.largeTitle.weight(.heavy))
                        .foregroundStyle(theme.textPrimary)
                    
                    Text("Version \(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0")")
                        .foregroundStyle(theme.textSecondary)
                    
                    Text("LevelUp helps you create and track missions, set reminders, and grow your habits in a fun way. You can also compete with friends to see who has the most missions completed!. A habit tracker basically, but with a lot more fun!")
                        .multilineTextAlignment(.center)
                        .foregroundStyle(theme.textPrimary)
                        .padding(.horizontal)
                    
                    Button(action: {
                        // Open feedback email
                        if let url = URL(string: "mailto:devpichardo@gmail.com") {
                            UIApplication.shared.open(url)
                        }
                    }) {
                        HStack {
                            Image(systemName: "envelope.fill")
                            Text("Send Feedback")
                        }
                        .font(.body.weight(.semibold))
                    }
                    .foregroundStyle(theme.primary)
                    
                    Button(action: {
                        // Open privacy policy URL
                        if let url = URL(string: "https://yourapp.com/privacy") {
                            UIApplication.shared.open(url)
                        }
                    }) {
                        HStack {
                            Image(systemName: "doc.text.fill")
                            Text("Privacy Policy")
                        }
                        .font(.body.weight(.semibold))
                    }
                    .foregroundStyle(theme.primary)
                    
                    Spacer()
                }
                .padding()
            }
            .navigationTitle("About")
            .navigationBarTitleDisplayMode(.inline)
            .background(theme.background.ignoresSafeArea())
        }
        
        
    }
}
#Preview {
    AboutView()
        .environment(\.theme, .dark)

}
