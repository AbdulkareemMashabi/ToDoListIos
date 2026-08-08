import EventKit
import UIKit

class CalendarManager {
    static let shared = CalendarManager()
    private let eventStore = EKEventStore()

    func requestAccess(completion: @escaping (Bool) -> Void) {
        if #available(iOS 17.0, *) {
            eventStore.requestFullAccessToEvents { granted, error in
                DispatchQueue.main.async {
                    completion(granted)
                }
            }
        } else {
            eventStore.requestAccess(to: .event) { granted, error in
                DispatchQueue.main.async {
                    completion(granted)
                }
            }
        }
    }

    func addEvent(
        title: String,
        description: String,
        startDate: Date,
        endDate: Date
    ) -> (Bool, String?) {
        let event = EKEvent(eventStore: eventStore)

        event.title = title
        event.notes = description
        event.startDate = startDate
        event.endDate = endDate

        if let defaultCalendar = eventStore.defaultCalendarForNewEvents {
            event.calendar = defaultCalendar
        } else {
            event.calendar = eventStore.calendars(for: .event).first
        }

        guard event.calendar != nil else {
            return (false, nil)
        }

        do {
            try eventStore.save(event, span: .thisEvent)
            return (true, event.eventIdentifier)
        } catch {
            return (false, nil)
        }
    }

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
