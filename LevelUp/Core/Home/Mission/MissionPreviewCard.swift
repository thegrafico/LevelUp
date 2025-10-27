import SwiftUI



struct MissionPreviewCard: View {
    @Environment(\.theme) private var theme
    @Environment(\.dismiss) private var dismiss
    var mission: Mission

    @State private var glow = false

    var body: some View {
        ZStack {
            // 🎨 Unified, clean background
            LinearGradient(
                colors: [
                    theme.background.opacity(0.95),
//                    theme.background.opacity(0.5)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 22) {
                // 🏅 Glowing icon
                ZStack {
                    Circle()
                        .fill(theme.primary.opacity(0.15))
                        .frame(width: 140, height: 140)
                        .shadow(color: theme.accent.opacity(glow ? 0.6 : 0.25), radius: 25)
                        .blur(radius: glow ? 0.8 : 4)
                        .scaleEffect(glow ? 1.07 : 1.0)
                        .animation(.easeInOut(duration: 1.8).repeatForever(autoreverses: true), value: glow)
                    

                    Image(systemName: mission.icon)
                        .font(.system(size: 60, weight: .bold))
                        .foregroundStyle(theme.accent)
                        .shadow(color: theme.accent.opacity(0.7), radius: 8, y: 3)
                }
                .onAppear { glow = true }

                // 🧾 Title
                Text(mission.title)
                    .font(.system(size: 26, weight: .heavy, design: .rounded))
                    .foregroundStyle(theme.textInverse.opacity(0.9))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                    .shadow(color: theme.textBlack, radius: 1, x:  1, y:  1)
                    .shadow(color: theme.textBlack, radius: 1, x: -1, y:  1)
                    .shadow(color: theme.textBlack, radius: 1, x:  1, y: -1)
                    .shadow(color: theme.textBlack, radius: 1, x: -1, y: -1)
                    .lineLimit(2)

                // ⚡ Stats Row
                HStack(spacing: 10) {
                    Label("\(mission.xp) XP", systemImage: "bolt.fill")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(theme.primary)

                    Text("•")
                        .foregroundStyle(.gray.opacity(0.7))

                    Text(mission.category.name)
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(.gray.opacity(0.95))

                    Text("•")
                        .foregroundStyle(.gray.opacity(0.7))

                    Text(mission.type == .global ? "GLOBAL" : "CUSTOM")
                        .font(.caption.weight(.bold))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(theme.accent.opacity(0.15))
                        .foregroundStyle(theme.primary)
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                }

                Divider().overlay(Color.white.opacity(0.15)).padding(.vertical, 8)

                // 🧠 Description with style
                VStack(alignment: .leading, spacing: 10) {
                    Text("Details")
                        .shadow(color: .black.opacity(0.4), radius: 5, y: 3)
                        .font(.headline.weight(.bold))
                        .fontDesign(.rounded)
                        .foregroundStyle(theme.textPrimary)
                        .textCase(.uppercase)
                        .padding(.bottom, 4)
                        
                    
                    Text(mission.details ?? "Stay focused for 30 minutes without distractions. You win if you avoid opening social media!")
                        .font(.callout)
                        .fontDesign(.rounded)
                        .foregroundStyle(theme.textPrimary)
                        .lineSpacing(4)
                        .padding(12)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(
                            RoundedRectangle(cornerRadius: 14)
                                .fill(theme.cardBackground.opacity(0.95))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 14)
                                        .stroke(theme.accent.opacity(0.2), lineWidth: 1)
                                )
                        )
                        .shadow(color: .black.opacity(0.8), radius: 4, y: 2)
                }
                .padding(.horizontal)

                Spacer()

                // 🎁 Close Button
                Button {
                    dismiss()
                } label: {
                    Label("Close", systemImage: "xmark.circle.fill")
                        .font(.headline.weight(.semibold))
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(
                            LinearGradient(
                                colors: [theme.accent, theme.primary],
                                startPoint: .leading, endPoint: .trailing
                            )
                            .cornerRadius(14)
                        )
                        .foregroundStyle(.white)
                        .shadow(color: theme.accent.opacity(0.6), radius: 6, y: 3)
                }
                .padding(.horizontal)
                .padding(.bottom, 12)
            }
            .padding(.vertical, 32)
        }
        .onAppear {
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        }
    }
}

#Preview {
    MissionPreviewCard(
        mission: Mission(
            title: "Defeat the Procrastination Boss",
            xp: 60,
            type: .custom,
            details: "Stay focused for 30 minutes without distractions.\nYou win if you avoid opening social media or switching tasks.",
            icon: "flame.fill",
        )
    )
    .environment(\.theme, .orange)
}
