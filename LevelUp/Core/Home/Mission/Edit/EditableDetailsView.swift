//
//  EditableDetailsView.swift
//  LevelUp
//
//  Created by Raúl Pichardo Avalo on 11/2/25.
//

import SwiftUI

struct EditableDetailsView: View {
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
            
            ZStack(alignment: .bottomTrailing) {
                TextEditor(text: Binding(
                    get: { mission.details ?? "" },
                    set: {
                        // Limit to ~140 characters
                        let limited = String($0.prefix(140))
                        mission.details = limited
                    }
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
                .frame(height: 140)
                .onAppear {
                    lastValidDetails = mission.details ?? ""
                }
                .onChange(of: isFocused) { _, focused in
                    if !focused {
                        validateAndSave()
                    }
                }
                
                // 💬 Placeholder — this is the magic
                if (mission.details ?? "").isEmpty {
                    Text("Tap to add a description...")
                        .font(.callout)
                        .fontDesign(.rounded)
                        .foregroundStyle(theme.textSecondary.opacity(0.5))
                        .padding(.horizontal, 16)
                        .padding(.vertical, 14)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .allowsHitTesting(false)
                }
                
                // 👇 Counter (unchanged)
                if isFocused {
                    Text("\((mission.details ?? "").count)/140")
                        .font(.caption2.monospacedDigit().weight(.semibold))
                        .foregroundStyle(
                            (mission.details ?? "").count >= 135
                            ? theme.destructive.opacity(0.8)
                            : theme.textSecondary.opacity(0.7)
                        )
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(theme.background.opacity(0.8))
                        )
                        .padding([.bottom, .trailing], 6)
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
