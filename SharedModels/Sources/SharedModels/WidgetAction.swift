import Foundation
import WidgetKit

public enum WidgetAction {
    public static let suiteName = "group.com.abdulkareem.ToDoList.widget"

    public static func buildURL(docID: String, subTaskIndex: Int? = nil) -> URL? {
        var components = URLComponents(string: "todolist://widget")!
        var queryItems = [
            URLQueryItem(name: "docID", value: docID)
        ]
        if let index = subTaskIndex {
            queryItems.append(URLQueryItem(name: "index", value: String(index)))
        }
        components.queryItems = queryItems
        return components.url
    }

    public static func parse(url: URL) -> (docID: String, subTaskIndex: Int?)? {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
              let docID = components.queryItems?.first(where: { $0.name == "docID" })?.value else {
            return nil
        }
        let indexStr = components.queryItems?.first(where: { $0.name == "index" })?.value
        let index = indexStr.flatMap { Int($0) }
        return (docID, index)
    }
}
