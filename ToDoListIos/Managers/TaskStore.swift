import Foundation

/// In-memory cache of the user's tasks, shared across the dashboard and
/// widget-action processor.
final class TaskStore: ObservableObject {
    @Published var tasks: [ToDoTask] = []
}
