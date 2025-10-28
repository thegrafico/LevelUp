import SwiftUI

#if canImport(UIKit)
extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
#endif

struct MissionPreviewCard: View {
    @Environment(\.theme) private var theme
    @Environment(\.dismiss) private var dismiss
    @Bindable var mission: Mission

    
    @State private var lastValidTitle: String = ""
    @State private var showTitleWarning: Bool = false
    @State private var glow = false
    @FocusState private var isEditingTitle: Bool

    var body: some View {
        ZStack {
            // 🎨 Background
            LinearGradient(
                colors: [theme.background.opacity(0.95)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            .onTapGesture {
                    hideKeyboard()
                }

            VStack(spacing: 22) {
                // 🏅 Icon
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

                // 🧾 Title (editable but same design)
                ZStack {
                    TextField("", text: $mission.title)
                        .focused($isEditingTitle)
                        .onAppear {
                            // Initialize with the mission’s current title
                            lastValidTitle = mission.title
                        }
                        .onChange(of: isEditingTitle) {_,focused in
                            if !focused {
                                // When the field loses focus, validate
                                let trimmed = mission.title.trimmingCharacters(in: .whitespacesAndNewlines)
                                if trimmed.isEmpty {
                                    showTitleWarning = true
                                    mission.title = lastValidTitle // 👈 revert to the last valid one
                                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                        // Optional: Shake animation feedback
                                    }
                                    // Hide warning after delay
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                                        withAnimation(.easeOut) { showTitleWarning = false }
                                    }
                                } else {
                                    mission.title = trimmed
                                }
                            }
                        }
                        .multilineTextAlignment(.center)
                        .font(.system(size: 26, weight: .heavy, design: .rounded))
                        .foregroundStyle(theme.textInverse.opacity(0.9))
                        .padding(.horizontal)
                        .shadow(color: theme.textBlack, radius: 1, x: 1, y: 1)
                        .shadow(color: theme.textBlack, radius: 1, x: -1, y: 1)
                        .shadow(color: theme.textBlack, radius: 1, x: 1, y: -1)
                        .shadow(color: theme.textBlack, radius: 1, x: -1, y: -1)
                        .lineLimit(2)
                        .textFieldStyle(.plain)
                        .opacity(isEditingTitle ? 1 : 0.001) // invisible when not editing
                        .allowsHitTesting(isEditingTitle)
                    
                    // overlay non-editable text for same look
                    if !isEditingTitle {
                        Text(mission.title)
                            .font(.system(size: 26, weight: .heavy, design: .rounded))
                            .foregroundStyle(theme.textInverse.opacity(0.9))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                            .shadow(color: theme.textBlack, radius: 1, x: 1, y: 1)
                            .shadow(color: theme.textBlack, radius: 1, x: -1, y: 1)
                            .shadow(color: theme.textBlack, radius: 1, x: 1, y: -1)
                            .shadow(color: theme.textBlack, radius: 1, x: -1, y: -1)
                            .lineLimit(2)
                            .onTapGesture {
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    isEditingTitle = true
                                }
                            }
                    }
                }

                // ⚡ Stats Row
                HStack(spacing: 10) {
                    EditableXPView(mission: mission)

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

                EditableDetailsView(mission: mission)
       

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
                            LinearGradient(colors: [theme.accent, theme.primary], startPoint: .leading, endPoint: .trailing)
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
        .overlay(alignment: .topTrailing) {
            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.title2)
                    .foregroundStyle(theme.textSecondary.opacity(0.7))
                    .padding(16)
            }
        }
        .onAppear {
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        }
    }
    
    private struct EditableXPView: View {
        @Environment(\.theme) private var theme
        @Bindable var mission: Mission
        
        @State private var isEditingXP = false
        @State private var lastValidXP: Int = 0
        @State private var showXPWarning = false
        
        private let allowedXPValues = [10, 15, 20, 25]
        
        var body: some View {
            ZStack {
                if isEditingXP {
                    HStack(spacing: 8) {
                        ForEach(allowedXPValues, id: \.self) { xpValue in
                            Text("\(xpValue)")
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(
                                    mission.xp == xpValue ? theme.textInverse : theme.textPrimary
                                )
                                .padding(.horizontal, 10)
                                .padding(.vertical, 6)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(mission.xp == xpValue ? theme.primary : theme.cardBackground)
                                )
                                .onTapGesture {
                                    withAnimation(.easeInOut) {
                                        mission.xp = xpValue
                                        isEditingXP = false
                                    }
                                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                }
                        }
                    }
                    .transition(.scale.combined(with: .opacity))
                } else {
                    Label("\(mission.xp) XP", systemImage: "bolt.fill")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(theme.primary)
                        .onTapGesture {
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                lastValidXP = mission.xp
                                isEditingXP = true
                            }
                        }
                }
            }
            .onChange(of: isEditingXP) { _, editing in
                if !editing {
                    // Validate XP in case user cancels out somehow
                    if !allowedXPValues.contains(mission.xp) {
                        mission.xp = lastValidXP
                        showXPWarning = true
                        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                            withAnimation { showXPWarning = false }
                        }
                    }
                }
            }
            .overlay(
                Group {
                    if showXPWarning {
                        Text("⚠️ Invalid XP reverted")
                            .font(.caption2.weight(.semibold))
                            .foregroundStyle(.red)
                            .transition(.opacity)
                            .offset(y: -24)
                    }
                }
            )
        }
    }
    
    private struct EditableDetailsView: View {
        @Environment(\.theme) private var theme
        @Bindable var mission: Mission
        
        @FocusState private var isFocused: Bool
        @State private var isEditing: Bool = false
        @State private var lastValidDetails: String = ""
        @State private var showDetailsWarning = false
        
        var body: some View {
            VStack(alignment: .leading, spacing: 10) {
                Text("Details")
                    .shadow(color: .black.opacity(0.4), radius: 5, y: 3)
                    .font(.headline.weight(.bold))
                    .fontDesign(.rounded)
                    .foregroundStyle(theme.textPrimary)
                    .textCase(.uppercase)
                    .padding(.bottom, 4)
                
                ZStack(alignment: .topLeading) {
                    if isEditing {
                        // 📝 Editable mode
                        TextEditor(text: Binding(
                            get: { mission.details ?? "" },
                            set: { mission.details = $0 }
                        ))
                        .focused($isFocused)
                        .font(.callout)
                        .fontDesign(.rounded)
                        .foregroundStyle(theme.textPrimary)
                        .scrollContentBackground(.hidden)
                        .padding(10)
                        .background(
                            RoundedRectangle(cornerRadius: 14)
                                .fill(theme.cardBackground.opacity(0.95))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 14)
                                        .stroke(theme.accent.opacity(0.2), lineWidth: 1)
                                )
                        )
                        .shadow(color: .black.opacity(0.8), radius: 4, y: 2)
                        .frame(minHeight: 80, maxHeight: 160)
                        .onAppear {
                            lastValidDetails = mission.details ?? ""
                            // 👇 ensure focus once the editor is actually on screen
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                isFocused = true
                            }
                        }
                        .onChange(of: isFocused) { _, focused in
                            if !focused {
                                validateAndSave()
                            }
                        }
                    } else {
                        // 📄 Display mode
                        Text(mission.details?.isEmpty == false
                             ? mission.details!
                             : "No description yet. Tap to add details.")
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
                            .contentShape(Rectangle()) // ensures whole area is tappable
                            .onTapGesture {
                                withAnimation(.easeInOut(duration: 0.25)) {
                                    isEditing = true
                                }
                            }
                    }
                }
                
                if showDetailsWarning {
                    Text("⚠️ Details can’t be empty — reverted.")
                        .font(.footnote.weight(.semibold))
                        .foregroundStyle(.red)
                        .transition(.opacity.combined(with: .move(edge: .top)))
                }
            }
            .padding(.horizontal)
            .animation(.spring(response: 0.4, dampingFraction: 0.8), value: showDetailsWarning)
        }
        
        private func validateAndSave() {
            let trimmed = (mission.details ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
            if trimmed.isEmpty {
                showDetailsWarning = true
                mission.details = lastValidDetails
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    withAnimation(.easeOut) { showDetailsWarning = false }
                }
            } else {
                mission.details = trimmed
            }
            withAnimation(.easeInOut(duration: 0.25)) {
                isEditing = false
            }
        }
    }
}

#Preview {
    MissionPreviewCard(
        mission: Mission(
            title: "Defeat the Procrastination Boss",
            xp: 60,
            type: .custom,
            details: "Stay focused for 30 minutes without distractions. You win if you avoid opening social media or switching tasks.",
            icon: "flame.fill"
        )
    )
    .environment(\.theme, .orange)
}
