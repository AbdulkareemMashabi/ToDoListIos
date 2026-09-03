//
//  ToDoAppWidgetBundle.swift
//  ToDoAppWidget
//
//  Created by Abdulkareem Mashabi on 04/03/1448 AH.
//

import WidgetKit
import SwiftUI

@main
struct ToDoAppWidgetBundle: WidgetBundle {
    var body: some Widget {
        ToDoAppWidget()
        ToDoAppWidgetLiveActivity()
        if #available(iOS 18.0, *) {
            ToDoAppWidgetControl()
        }
    }
}
