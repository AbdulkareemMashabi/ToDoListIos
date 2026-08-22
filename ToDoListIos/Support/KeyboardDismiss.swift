import SwiftUI
import UIKit

extension View {
    /// Adds an invisible tap layer that resigns the first responder when tapped,
    /// providing the same "tap outside to dismiss the keyboard" behavior as a
    /// full-screen `Rectangle().onTapGesture` — without swallowing UI hits.
    func dismissKeyboardOnTap() -> some View {
        contentShape(Rectangle())
            .onTapGesture {
                UIApplication.shared.sendAction(
                    #selector(UIResponder.resignFirstResponder),
                    to: nil, from: nil, for: nil
                )
            }
    }
}
