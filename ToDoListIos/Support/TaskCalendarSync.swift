import Foundation

/// Coordinates calendar side-effects (add / update / remove) triggered by
/// task mutations. Handles access requests and the associated toast / alert
/// feedback where appropriate.
@MainActor
enum TaskCalendarSync {

    /// Best-effort cleanup — removes the calendar event associated with a
    /// deleted task. No-op if `eventId` is empty or calendar access is
    /// declined. Deliberately silent on success and failure so it doesn't
    /// clutter the delete flow.
    static func remove(eventId: String) async {
        guard !eventId.isEmpty else { return }

        let granted = await CalendarManager.shared.requestAccess()
        guard granted else { return }

        _ = CalendarManager.shared.removeEvent(eventId: eventId)
    }

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
