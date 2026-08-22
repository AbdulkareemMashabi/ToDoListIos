import Foundation
import AVFoundation

/// Plays the app's completion sound. Holds a strong reference to the
/// `AVAudioPlayer` so playback isn't cut off by ARC while the sound is playing.
@MainActor
enum SoundPlayer {
    private static var player: AVAudioPlayer?

    static func playCorrect() {
        guard let url = Bundle.main.url(forResource: "correct_sound", withExtension: "mp3") else {
            return
        }
        do {
            player = try AVAudioPlayer(contentsOf: url)
            player?.play()
        } catch {
            // Silently ignore playback errors — sound is a nice-to-have cue.
        }
    }
}
