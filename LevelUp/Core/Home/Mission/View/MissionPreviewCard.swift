import SwiftUI

#if canImport(UIKit)
extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
#endif

func triggerDeniedFeedback(active: Binding<Bool>, offset: Binding<CGFloat>) {
    UIImpactFeedbackGenerator(style: .rigid).impactOccurred()
    
    // 🔁 Shake animation
    withAnimation(Animation.spring(response: 0.1, dampingFraction: 0.3).repeatCount(3, autoreverses: true)) {
        offset.wrappedValue = 8
    }
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
        offset.wrappedValue = 0
    }
    
    // 🔴 Flash red
    active.wrappedValue = true
    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
        withAnimation(.easeOut) { active.wrappedValue = false }
    }
}


struct MissionPreviewCard: View {
    @Environment(\.theme) private var theme
    @Environment(\.dismiss) private var dismiss
    @Environment(\.currentUser) private var user

    @EnvironmentObject private var notificationManager: NotificationManager
    
    @Bindable var mission: Mission
    @State private var openSheetToShareMission: Bool = false
    
    private var isCustom: Bool {
        mission.isCustom
    }
    
    @State private var lastValidTitle: String = ""
    @State private var showTitleWarning: Bool = false
    @State private var glow = false
    @State private var deniedTitleEdit = false
    @State private var titleShakeOffset: CGFloat = 0
    
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
            
            ScrollView {
                
                ZStack {
                    
                    Color.clear
                        .contentShape(Rectangle()) // make it tappable
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
                        .padding(.top, 20)
                        
                        .onAppear { glow = true }
                        
                        // 🧾 Title (editable but same design)
                        ZStack {
                            
                            if isCustom {
                                TextField("", text: $mission.title)
                                    .focused($isEditingTitle)
                                    .onAppear {
                                        // Initialize with the mission’s current title
                                        lastValidTitle = mission.title
                                    }
                                    .onChange(of: isEditingTitle) {_,focused in
                                        if !focused && isCustom  {
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
                            }
                            // overlay non-editable text for same look
                            if !isEditingTitle || !isCustom {
                                Text(mission.title)
                                    .font(.system(size: 26, weight: .heavy, design: .rounded))
                                    .foregroundStyle(deniedTitleEdit ? theme.destructive : theme.textInverse.opacity(0.9))
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal)
                                    .shadow(color: theme.textBlack, radius: 1, x: 1, y: 1)
                                    .shadow(color: theme.textBlack, radius: 1, x: -1, y: 1)
                                    .shadow(color: theme.textBlack, radius: 1, x: 1, y: -1)
                                    .shadow(color: theme.textBlack, radius: 1, x: -1, y: -1)
                                    .lineLimit(2)
                                    .offset(x: titleShakeOffset)
                                    .onTapGesture {
                                        if isCustom {
                                            withAnimation(.easeInOut(duration: 0.3)) {
                                                isEditingTitle = true
                                            }
                                        } else {
                                            triggerDeniedFeedback(active: $deniedTitleEdit, offset: $titleShakeOffset)
                                        }
                                    }
                            }
                        }
                        
                        // ⚡ Stats Row
                        HStack(spacing: 10) {
                            EditableXPView(mission: mission, canEdit: isCustom)
                            
                            Text("•")
                                .foregroundStyle(theme.textSecondary.opacity(0.5))
                            
                            Text(mission.category.name)
                                .font(.subheadline.weight(.medium))
                                .foregroundStyle(theme.textSecondary.opacity(0.5))
                            
                            Text("•")
                                .foregroundStyle(theme.textSecondary.opacity(0.5))
                            
                            Button {
                                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                
                                if isCustom {
                                    openSheetToShareMission.toggle()
                                }
                                
                            } label: {
                                HStack(spacing: 4) {
                                    
                                    if isCustom {
                                        Image(systemName: "square.and.arrow.up") // share icon
                                            .font(.caption.bold())
                                    }
                                    Text(mission.type == .global ? "GLOBAL" : "CUSTOM")
                                        .font(.caption.weight(.bold))
                                        .lineLimit(1)
                                }
                                .padding(.horizontal, 10)
                                .padding(.vertical, 6)
                                .background(
                                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                                        .fill(theme.accent.opacity(0.18))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 8)
                                                .stroke(theme.accent.opacity(0.4), lineWidth: 1)
                                        )
                                        .shadow(color: theme.accent.opacity(0.25), radius: 3, y: 2)
                                )
                                .foregroundStyle(theme.primary)
                                .contentShape(Rectangle()) // expands tap area
                            }
                            .buttonStyle(.scaleOnTap) // 👈 custom animation (below)
                        }
                        
                        Divider().overlay(Color.white.opacity(0.15)).padding(.vertical, 8)
                        
                        EditableDetailsView(mission: mission)
//                            .disabled(!isCustom)
                        
                        ReminderSection(reminder: $mission.reminder, style: .inline)
                            .padding(.vertical, 20)
                    }
                }
            }
            .scrollIndicators(.hidden)
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
            print("Appeared Mission Preview")
            mission.refreshReminderStatus()
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        }
        .onDisappear {
            Task {
                if mission.reminder.isEnabled {
                    print("Schedule Mission")
                    await notificationManager.schedule(for: mission)
                } else {
                    notificationManager.cancel(for: mission)
                }
            }
            
        }
        .sheet(isPresented: $openSheetToShareMission) {
            SendMissionView(mission: mission, friends: user.friends)
        }
    }
}

#Preview {
    MissionPreviewCard(
        mission: Mission(
            title: "Defeat the Procrastination Boss",
            xp: 60,
            type: .custom,
            details: "This is a global mission",
            icon: "flame.fill"
        )
    )
    .environment(\.theme, .orange)
    .environmentObject(NotificationManager())
    .environment(\.currentUser, User.sampleUserWithLogs())
}
