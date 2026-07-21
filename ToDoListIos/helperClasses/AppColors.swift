//
//  NavigationManager.swift
//  ToDoListIos
//
//  Created by Abdulkareem Mashabi on 21/10/1447 AH.
//

import Foundation
import SwiftUI

enum ColorsToDo: Hashable, CaseIterable {
    case red
    case blue
    case orange
    case green
    
    var image: String {

        switch self {

        case .red:
            return "red"

        case .blue:
            return "blue"

        case .orange:
            return "orange"

        case .green:
            return "green"
        }
    }

    var color: String {

        switch self {

        case .red:
            return "#FF3B30"

        case .blue:
            return "#32ADE6"

        case .orange:
            return "#FF9500"

        case .green:
            return "#34C759"
        }
    }
}


class AppColors: ObservableObject {

    @Published var colors: [ColorsToDo] = []

    func addingNewColor() {

        let allColors = ColorsToDo.allCases

        var remainingColors = allColors.filter {
            !colors.contains($0)
        }

        // Reset if all colors used
        if remainingColors.isEmpty {

            colors.removeAll()

            remainingColors = allColors
        }

        // Add random color
        if let randomColor = remainingColors.randomElement() {
            colors.append(randomColor)
        }
    }
    
    func getImage() -> ColorsToDo {
        addingNewColor()
        return colors.last ?? ColorsToDo.red
    }
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)

        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)

        let r = Double((int >> 16) & 0xFF) / 255
        let g = Double((int >> 8) & 0xFF) / 255
        let b = Double(int & 0xFF) / 255

        self.init(.sRGB, red: r, green: g, blue: b, opacity: 1)
    }
}
