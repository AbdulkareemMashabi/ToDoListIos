import Foundation

/// Coordinates the "add task to calendar" side-effect used by both
/// `CreateNewTask` and `TaskDetails`. Handles access requests, event
/// creation, event updates and the associated toast / alert feedback.
@MainActor
enum TaskCalendarSync {

    /// Syncs a task with the user's calendar. If `existingEventId` is empty,
    /// a new event is created; otherwise the existing event is updated.
    /// Returns the identifier of the event that should be stored on the task
    /// (empty string when the user declined access or an error occurred).
    static func sync(
        title: String,
        description: String,
        endDate: Date,
        existingEventId: String,
        shouldSync: Bool,
        toastManager: ToastManager,
        alertManager: AlertManager
    ) async -> String {
        guard shouldSync else { return existingEventId }

        let granted = await CalendarManager.shared.requestAccess()
        guard granted else {
            alertManager.show(message: localized("task.calendarAccessDenied"))
            return existingEventId
        }

        if existingEventId.isEmpty {
            let eventId = CalendarManager.shared.addEvent(
                title: title,
                description: description,
                startDate: Date(),
                endDate: endDate
            )
            if let eventId {
                toastManager.show(localized("task.addedToCalendar"))
                return eventId
            } else {
                alertManager.show(message: localized("task.failedToAddToCalendar"))
                return ""
            }
        } else {
            let updated = CalendarManager.shared.updateEvent(
                eventId: existingEventId,
                title: title,
                description: description,
                startDate: Date(),
                endDate: endDate
            )
            if updated {
                toastManager.show(localized("task.updatedInCalendar"))
            } else {
                alertManager.show(message: localized("task.failedToUpdateCalendar"))
            }
            return existingEventId
        }
    }
}
