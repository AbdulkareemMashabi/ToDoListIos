//
//  NavigationManager.swift
//  ToDoListIos
//
//  Created by Abdulkareem Mashabi on 21/10/1447 AH.
//

import SwiftUI

/// Backs the app-wide navigation. On regular widths (iPad, unfolded iPhone
/// Duo) the root is a `NavigationSplitView`: Dashboard lives in the detail
/// column driven by `path`, and TaskDetails lives in the sidebar column
/// driven by `selectedTask`. On compact widths (standard iPhones, folded
/// iPhone Duo, Slide Over) the root falls back to a single `NavigationStack`
/// where TaskDetails is pushed onto `path` via the `.taskDetails` route so
/// the system back button behaves normally.
final class NavigationManager: ObservableObject {
    @Published var path: [Route] = []
    @Published var selectedTask: ToDoTask?
    /// Regular-width only: forces the split view's sidebar (TaskDetails)
    /// visible when opening a task, or hides it back to detail-only after
    /// save. Ignored on compact widths since we switch to `NavigationStack`.
    @Published var columnVisibility: NavigationSplitViewVisibility = .detailOnly
}

enum Route: Hashable {
    case login
    case register
    case createNewTask
    case forgetPassword
    case accountDeletion
    case taskDetails(ToDoTask)
}
