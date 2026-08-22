import EventKit
import UIKit

@MainActor
final class CalendarManager {
    static let shared = CalendarManager()
    private let eventStore = EKEventStore()

    private init() {}

    /// Requests calendar access, transparently choosing the correct API for the OS version.
    func requestAccess() async -> Bool {
        do {
            if #available(iOS 17.0, *) {
                return try await eventStore.requestFullAccessToEvents()
            } else {
                return try await eventStore.requestAccess(to: .event)
            }
        } catch {
            return false
        }
    }

    /// Creates a new calendar event. Returns the created event's identifier
    /// on success, or `nil` when saving fails.
    func addEvent(
        title: String,
        description: String,
        startDate: Date,
        endDate: Date
    ) -> String? {
        let event = EKEvent(eventStore: eventStore)
        event.title = title
        event.notes = description
        event.startDate = startDate
        event.endDate = endDate
        event.calendar = eventStore.defaultCalendarForNewEvents
            ?? eventStore.calendars(for: .event).first

        guard event.calendar != nil else { return nil }

        do {
            try eventStore.save(event, span: .thisEvent)
            return event.eventIdentifier
        } catch {
            return nil
        }
    }

    /// Updates an existing event's fields. Returns `false` if the event
    /// isn't found or the save fails.
    func updateEvent(
        eventId: String,
        title: String,
        description: String,
        startDate: Date,
        endDate: Date
    ) -> Bool {
        guard let event = eventStore.event(withIdentifier: eventId) else {
            return false
        }
        event.title = title
        event.notes = description
        event.startDate = startDate
        event.endDate = endDate

        do {
            try eventStore.save(event, span: .thisEvent)
            return true
        } catch {
            return false
        }
    }
}
