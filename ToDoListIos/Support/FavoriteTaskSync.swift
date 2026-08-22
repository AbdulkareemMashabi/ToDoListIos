import Foundation
import WidgetKit
import SharedModels

/// Persists the currently-favorite task to the shared app group so the widget
/// can render it, and refreshes all widget timelines.
@MainActor
func saveFavoriteTaskInStorage(_ task: ToDoTask?) {
    let shared = UserDefaults(suiteName: AppConstants.appGroupIdentifier)
    shared?.removeObject(forKey: AppConstants.favoriteTaskDefaultsKey)

    if let task, let data = try? JSONEncoder().encode(task) {
        shared?.set(data, forKey: AppConstants.favoriteTaskDefaultsKey)
    }

    WidgetCenter.shared.reloadAllTimelines()
}

/// Applies a widget-originated status toggle (main or sub-task) to the shared
/// favorite task, syncs it to Firestore, updates the in-memory task store,
/// and mirrors the in-app completion feedback (sound + done animation).
@MainActor
func processWidgetAction(url: URL, taskStore: TaskStore, lottieManager: LottieManager) {
    guard let parsed = WidgetAction.parse(url: url) else { return }

    let shared = UserDefaults(suiteName: AppConstants.appGroupIdentifier)
    guard
        let data = shared?.data(forKey: AppConstants.favoriteTaskDefaultsKey),
        var task = try? JSONDecoder().decode(ToDoTask.self, from: data),
        task.documentID == parsed.docID
    else { return }

    let didCompleteItem: Bool
    let didCompleteMainTask: Bool

    if let index = parsed.subTaskIndex, index < task.subTasks.count {
        task.subTasks[index].status.toggle()
        task.mainTask.status = task.subTasks.allSatisfy(\.status)
        didCompleteItem = task.subTasks[index].status
        didCompleteMainTask = didCompleteItem && task.mainTask.status
    } else {
        task.mainTask.status.toggle()
        for i in task.subTasks.indices {
            task.subTasks[i].status = task.mainTask.status
        }
        didCompleteItem = task.mainTask.status
        didCompleteMainTask = task.mainTask.status
    }

    do {
        try updateTaskAPI(task: task)
    } catch {
        print("Widget action sync failed: \(error.localizedDescription)")
    }

    saveFavoriteTaskInStorage(task)

    if let index = taskStore.tasks.firstIndex(where: { $0.documentID == task.documentID }) {
        taskStore.tasks[index] = task
    }

    // Only fire completion cues when the widget action moved the item to done
    // (matching in-app behavior — un-completing is silent).
    if didCompleteItem {
        SoundPlayer.playCorrect()
    }
    if didCompleteMainTask {
        lottieManager.isDoneLottieEnabled = true
    }
}
