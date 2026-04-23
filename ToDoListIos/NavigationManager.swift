//
//  NavigationManager.swift
//  ToDoListIos
//
//  Created by Abdulkareem Mashabi on 21/10/1447 AH.
//

import Foundation

class NavigationManager: ObservableObject {
    @Published var path: [Route] = []
}

enum Route: Hashable {
    case login
    case register
}
