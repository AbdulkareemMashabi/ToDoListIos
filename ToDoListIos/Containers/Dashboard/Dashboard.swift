//
//  Dashboard.swift
//  ToDoListIos
//
//  Created by Abdulkareem Mashabi on 07/05/1447 AH.
//

import SwiftUI

struct Dashboard: View {
    @EnvironmentObject private var navigationManager: NavigationManager
    var body: some View {
        VStack {
            Image("emptyListPic")
                .imageScale(.large)
            Text("You don't have tasks").fontWeight(.bold)
            Text("To create new task click on the plus (+) button").fontWeight(.bold).foregroundStyle(.gray)
            NavigationLink(value: Route.createNewTask) {
                Image(systemName: "plus")
                    .padding(.vertical, 12)
                    .padding(.horizontal, 8)
            }
            .buttonStyle(.borderedProminent)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.top, 40)
        }.customToolbar(                title: "My Wishes",
                                        leftButtons: [],
                                        rightButtons: [
                                            AnyView(Button { } label: {
                                                Image(systemName: "globe").foregroundStyle(.blue)
                                            }),
                                            AnyView(Button {
                                                navigationManager.path.append(.register)
                                            } label: {
                                                Image(systemName: "cloud").foregroundStyle(.blue)
                                            })
                                        ]).padding()
    }
}

#Preview {
    Dashboard()
}
