import Foundation

public enum TaskStatusColor {
    public static let dateFormat = "dd/MM/yyyy"

    /// Returns the color that should be used to indicate a task's status,
    /// based on whether it's completed and how its due date compares to today.
    public static func borderColor(dueDate: String, isCompleted: Bool) -> ColorsToDo {
        guard !dueDate.isEmpty else {
            return isCompleted ? .green : .orange
        }

        let days = daysUntil(dueDate: dueDate)

        if isCompleted { return .green }
        return days >= 0 ? .orange : .red
    }

    /// Returns the number of days between today and the given `dd/MM/yyyy` date string.
    /// Returns 0 if the date can't be parsed.
    public static func daysUntil(dueDate: String) -> Int {
        let formatter = DateFormatter()
        formatter.dateFormat = dateFormat

        guard let endDate = formatter.date(from: dueDate) else {
            return 0
        }

        let calendar = Calendar.current
        let startDate = calendar.startOfDay(for: Date())
        let components = calendar.dateComponents([.day], from: startDate, to: endDate)
        return components.day ?? 0
    }
}
