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
