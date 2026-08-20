import Foundation

class TaskStore: ObservableObject {
    @Published var tasks: [ToDoTask] = []
}
