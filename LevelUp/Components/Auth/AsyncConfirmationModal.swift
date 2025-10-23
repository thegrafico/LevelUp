import SwiftUI

struct AsyncConfirmationModal: View {
    @Environment(\.theme) private var theme
    
    @Binding var isPresented: Bool
    
    var title: String
    var message: String?
    var confirmButtonTitle: String = "Confirm"
    var cancelButtonTitle: String = "Cancel"
    var confirmAction: () async throws -> Void
    var cancelAction: (() async throws -> Void?)? = nil
    var closeOnTapOutside: Bool = false
    
    @State private var isLoading = false
    @State private var didSucceed = false
    @State private var errorMessage: String?
    
    var body: some View {
        ZStack {
            // Full-screen overlay
            Color.black.opacity(0.001)
                .ignoresSafeArea()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .zIndex(0)
                .onTapGesture {
                    if closeOnTapOutside {
                        isPresented = false
                    }
                    // optional: close modal or just block tap
                }
            
            // 🌌 MAIN MODAL
            VStack(spacing: 20) {
                // Title
                Text(title)
                    .font(.title3.weight(.bold))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(theme.textPrimary)
                    .shadow(color: theme.primary.opacity(0.3), radius: 4, y: 1)
                
                if let msg = message {
                    Text(msg)
                        .font(.subheadline.weight(.medium))
                        .multilineTextAlignment(.center)
                        .foregroundStyle(theme.textSecondary)
                        .padding(.horizontal)
                }
                
                // Error
                if let err = errorMessage {
                    Text(err)
                        .font(.footnote.weight(.medium))
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                        .padding(.top, 6)
                        .transition(.opacity)
                }
                
                // Buttons
                HStack(spacing: 16) {
                    Button(cancelButtonTitle) {
                        
                        Task {
                            try await cancelAction?()
                            
                            withAnimation { isPresented = false }
                        }
                        
                    }
                    .buttonStyle(.bordered)
                    .tint(theme.textBlack)
                    .disabled(isLoading)
                    
                    Button(confirmButtonTitle) {
                        Task { await performConfirm() }
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(theme.primary)
                    .disabled(isLoading)
                    .overlay {
                        if isLoading {
                            ProgressView()
                                .scaleEffect(0.8)
                                .tint(.white)
                        }
                    }
                }
                .padding(.top, 8)
            }
            .padding(30)
            .frame(maxWidth: UIScreen.main.bounds.width * 0.8)
            .background(
                // ✨ Sleek glass card with glow
                RoundedRectangle(cornerRadius: theme.cornerRadiusLarge)
                    .fill(
                        LinearGradient(
                            colors: [
                                theme.cardBackground.opacity(0.9),
                                theme.cardBackground.opacity(0.7)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: theme.cornerRadiusLarge)
                            .stroke(
                                LinearGradient(
                                    colors: [
                                        theme.primary.opacity(0.5),
                                        theme.accent.opacity(0.3)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1.2
                            )
                    )
                    .shadow(color: theme.primary.opacity(0.5), radius: 25, y: 10)
                    .shadow(color: .black.opacity(0.8), radius: 40, y: 20)
            )
            .opacity(didSucceed ? 0 : 1)
            .scaleEffect(didSucceed ? 0.95 : 1)
            .animation(.spring(response: 0.4, dampingFraction: 0.8), value: didSucceed)
            .zIndex(1)
        }
        .transition(.opacity.combined(with: .scale))
 
    }
    
    @MainActor
    private func performConfirm() async {
        withAnimation { isLoading = true }
        errorMessage = nil
        
        do {
            try await confirmAction()
            withAnimation(.spring) {
                didSucceed = true
                isPresented = false
            }
        } catch {
            errorMessage = error.localizedDescription
        }
        
        withAnimation {
            isLoading = false
            didSucceed = false
        }
    }
}

#Preview {
    AsyncConfirmationModal(
        isPresented: .constant(true),
        title: "Cancel Friend Request?",
        message: "Are you sure you want to cancel your request to John?",
        confirmButtonTitle: "Yes, Cancel",
        cancelButtonTitle: "No",
        confirmAction: {
            try? await Task.sleep(nanoseconds: 1_000_000_000)
            
        },
    )
    .environment(\.theme, .blue)
    //    .preferredColorScheme(.dark)
}
