import SwiftUI
import Lottie

/// Root content shown inside the app's `NavigationStack`: plays the splash
/// Lottie once, then reveals the Dashboard. Also plays the "done" celebration
/// Lottie whenever `lottieManager.isDoneLottieEnabled` becomes true.
struct RootContentView: View {
    @State private var isSplashFinished = false

    @EnvironmentObject private var lottieManager: LottieManager

    var body: some View {
        VStack {
            if isSplashFinished {
                Dashboard().transition(.opacity)
            } else {
                LottieView(animation: .filepath(LottieAsset.splash.filepath))
                    .playbackMode(.playing(.toProgress(1, loopMode: .playOnce)))
                    .animationDidFinish { _ in
                        isSplashFinished = true
                    }
                    .transition(.opacity)
                    .background(Color(white: 0.9))
            }
        }
        .overlay {
            if lottieManager.isDoneLottieEnabled {
                LottieView(animation: .filepath(LottieAsset.done.filepath))
                    .playbackMode(.playing(.toProgress(1, loopMode: .playOnce)))
                    .animationDidFinish { _ in
                        lottieManager.isDoneLottieEnabled = false
                    }
            }
        }
        .animation(.linear(duration: 0.3), value: isSplashFinished)
    }
}
