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

    var color: Color {

        switch self {

        case .red:
            return .red

        case .blue:
            return .blue

        case .orange:
            return .orange

        case .green:
            return .green
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
