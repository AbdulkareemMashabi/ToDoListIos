//
//  AppToken.swift
//  ToDoListIos
//
//  Created by Abdulkareem Mashabi on 21/10/1447 AH.
//

import Foundation

/// Publishes the currently authenticated user's token (Firebase UID or
/// device UUID for guest sessions). Empty string means "signed out".
final class AppToken: ObservableObject {
    @Published var token: String = ""
}
