import SwiftUI

// MARK: - Full-screen loading overlay

private struct FullScreenLoadingOverlay: ViewModifier {
    @EnvironmentObject private var loadingManager: LoadingManager

    func body(content: Content) -> some View {
        content.overlay {
            if loadingManager.isLoading {
                Color.black.opacity(0.3)
                    .ignoresSafeArea()
                    .overlay(
                        ProgressView()
                            .scaleEffect(1.5)
                            .tint(.white)
                    )
                    .zIndex(1000)
            }
        }
        .overlay {
            if loadingManager.isLoadingButton {
                Color.black.opacity(0.1)
                    .ignoresSafeArea()
                    .zIndex(999)
            }
        }
    }
}

// MARK: - Toast overlay

private struct ToastOverlay: ViewModifier {
    @EnvironmentObject private var toastManager: ToastManager

    func body(content: Content) -> some View {
        content.overlay(alignment: .top) {
            if toastManager.isShowing {
                ToastView(message: toastManager.message)
                    .padding(.top, 60)
                    .transition(.move(edge: .top).combined(with: .opacity))
                    .zIndex(2000)
            }
        }
        .animation(.easeInOut(duration: 0.3), value: toastManager.isShowing)
    }
}

// MARK: - Alert overlay

private struct AlertOverlay: ViewModifier {
    @EnvironmentObject private var alertManager: AlertManager

    func body(content: Content) -> some View {
        content.overlay {
            if alertManager.isPresented {
                Color.black.opacity(0.5)
                    .ignoresSafeArea()
                    .zIndex(999)
                    .overlay { alertCard }
            }
        }
    }

    private var alertCard: some View {
        VStack(spacing: 16) {
            Text(alertManager.title).font(.headline)
            Text(alertManager.message).multilineTextAlignment(.center)

            if alertManager.buttons.isEmpty {
                Button(localized("common.ok")) { alertManager.hide() }
            } else {
                ForEach(alertManager.buttons) { item in
                    ButtonComponent {
                        item.action()
                        alertManager.hide()
                    } label: {
                        Text(item.title)
                    }
                    .background(item.buttonVariant.color)
                    .formButtonStyle()
                }
            }
        }
        .padding()
        .background(.white)
        .cornerRadius(16)
        .frame(width: 327)
    }
}

// MARK: - Public entry point

extension View {
    /// Applies the app's shared overlays (loading spinner, toast, custom alert)
    /// to the receiver. Expects `LoadingManager`, `ToastManager` and
    /// `AlertManager` in the environment.
    func appOverlays() -> some View {
        modifier(FullScreenLoadingOverlay())
            .modifier(ToastOverlay())
            .modifier(AlertOverlay())
    }
}
