//
//  ToDoAppWidgetLiveActivity.swift
//  ToDoAppWidget
//
//  Created by Abdulkareem Mashabi on 04/03/1448 AH.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct ToDoAppWidgetAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var emoji: String
    }

    // Fixed non-changing properties about your activity go here!
    var name: String
}

struct ToDoAppWidgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: ToDoAppWidgetAttributes.self) { context in
            // Lock screen/banner UI goes here
            VStack {
                Text("Hello \(context.state.emoji)")
            }
            .activityBackgroundTint(Color.cyan)
            .activitySystemActionForegroundColor(Color.black)

        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI goes here.  Compose the expanded UI through
                // various regions, like leading/trailing/center/bottom
                DynamicIslandExpandedRegion(.leading) {
                    Text("Leading")
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text("Trailing")
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text("Bottom \(context.state.emoji)")
                    // more content
                }
            } compactLeading: {
                Text("L")
            } compactTrailing: {
                Text("T \(context.state.emoji)")
            } minimal: {
                Text(context.state.emoji)
            }
            .widgetURL(URL(string: "http://www.apple.com"))
            .keylineTint(Color.red)
        }
    }
}

extension ToDoAppWidgetAttributes {
    fileprivate static var preview: ToDoAppWidgetAttributes {
        ToDoAppWidgetAttributes(name: "World")
    }
}

extension ToDoAppWidgetAttributes.ContentState {
    fileprivate static var smiley: ToDoAppWidgetAttributes.ContentState {
        ToDoAppWidgetAttributes.ContentState(emoji: "😀")
     }
     
     fileprivate static var starEyes: ToDoAppWidgetAttributes.ContentState {
         ToDoAppWidgetAttributes.ContentState(emoji: "🤩")
     }
}

#Preview("Notification", as: .content, using: ToDoAppWidgetAttributes.preview) {
   ToDoAppWidgetLiveActivity()
} contentStates: {
    ToDoAppWidgetAttributes.ContentState.smiley
    ToDoAppWidgetAttributes.ContentState.starEyes
}
