import Foundation

/// Reads the stored auth token, refreshes the environment token, and fetches
/// all tasks for the signed-in user. On failure, presents an alert and returns
/// an empty array.
@MainActor
func loadTasksShared(
    appToken: AppToken,
    loadingManager: LoadingManager,
    alertManager: AlertManager
) async -> [ToDoTask] {
    let token = Storage.load(key: AppConstants.tokenKeychainKey) ?? ""
    appToken.token = token
    guard !token.isEmpty else { return [] }

    loadingManager.isLoading = true
    defer { loadingManager.isLoading = false }

    do {
        return try await fetchAllTasksAPI()
    } catch {
        alertManager.show(message: error.userFacingMessage)
        return []
    }
}

/// Replaces `TaskStore` with a fresh fetch after authentication (login /
/// register / guest). The caller is expected to have its own loading UI
/// (e.g. the login-button spinner), so this does *not* toggle
/// `LoadingManager.isLoading`. On success the tasks are replaced even if the
/// result is empty (new user with no tasks). On failure the store is left
/// untouched and an alert is presented.
@MainActor
func refreshTaskStore(taskStore: TaskStore, alertManager: AlertManager) async {
    do {
        taskStore.tasks = try await fetchAllTasksAPI()
    } catch {
        alertManager.show(message: error.userFacingMessage)
    }
}
