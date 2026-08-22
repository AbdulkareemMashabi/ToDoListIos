import Foundation
import SwiftUI

@MainActor
final class AppColors: ObservableObject {
    @Published private(set) var usedColors: [ColorsToDo] = []

    /// Returns the next color to use for a new task, cycling through the palette
    /// without repeating until all colors have been picked.
    func nextColor() -> ColorsToDo {
        var remaining = ColorsToDo.allCases.filter { !usedColors.contains($0) }
        if remaining.isEmpty {
            usedColors.removeAll()
            remaining = ColorsToDo.allCases
        }
        let picked = remaining.randomElement() ?? .red
        usedColors.append(picked)
        return picked
    }
}
