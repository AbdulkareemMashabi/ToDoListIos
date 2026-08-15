//
//  TaskToDo.swift
//  ToDoListIos
//
//  Created by Abdulkareem Mashabi on 11/02/1448 AH.
//

import SwiftUI

struct TaskListComponent: View {
    @EnvironmentObject private var navigationManager: NavigationManager
    @EnvironmentObject private var appToken: AppToken
    @EnvironmentObject private var appLanguageManager: AppLanguageManager
    @EnvironmentObject private var loadingmanager: LoadingManager
    @EnvironmentObject private var alertManager: AlertManager
    @Binding var tasks: [ToDoTask]
    @State private var showSwipeHint: Bool
    
    init(tasks: Binding<[ToDoTask]>){
        self._tasks = tasks
        print(tasks.count, "tasks")
        showSwipeHint = tasks.count == 1
    }
    
    func deleteTask(documentID: String) {
        let index = tasks.firstIndex(where: { $0.documentID == documentID })
        
        tasks.remove(at: index!)
    }
    
    func moveFavoriteToTop() {
        guard let index = tasks.firstIndex(where: { $0.favorite }) else {
            return
        }
        
        let favoriteTask = tasks.remove(at: index)
        tasks.insert(favoriteTask, at: 0)
    }
    
    func makeTaskUnFavorite(documentID: String) {
        if let index = tasks.firstIndex(where: { $0.favorite && ($0.documentID ?? "") != documentID })
        {
            do {
                var updatedTask = tasks[index]
                updatedTask.favorite = false
                try updateTaskAPI(task: updatedTask)
                tasks[index].favorite = false
            } catch {
                let message =
                (error as? LocalizedError)?.errorDescription ??
                error.localizedDescription
                
                alertManager.show(message: message)
            }
            
        }
        
        moveFavoriteToTop()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            List($tasks, id:\.mainTask.title) { $task in
                TaskRow(task: $task).frame(maxWidth: .infinity, minHeight: 60 ,alignment: .leading)
                    .listRowSeparator(.hidden)
                    .listRowInsets(    EdgeInsets(
                        top: 16,
                        leading: 5,
                        bottom: 0,
                        trailing: 5
                    ))
                    .listRowBackground(Color.clear)
                    .padding(.leading, 34)// leave room for the colored bar
                    .background(Color.white)
                    .cornerRadius(16)
                    .shadow(radius: 2)
                    .overlay(alignment: .leading) {
                        ZStack {
                            LeftRoundedRectangle(radius: 16)
                                .fill(Color(hex: task.mainTask.color))
                                .frame(width: 28)
                            
                            if(task.favorite) {
                                Image("filledStar").foregroundColor(Color(hex: "#dbdb07"))
                            }
                            
                        }
                    }.onChange(of: tasks.count){
                        showSwipeHint = tasks.count == 1
                    }.taskSwipeActions(task: $task, showSwipeHint: $showSwipeHint, deleteTask: deleteTask, makeTaskUnfavorite: makeTaskUnFavorite)
                
            }.scrollIndicators(.hidden).refreshable {
                let newTasks = await loadTasksShared(appToken: appToken, loadingManager: loadingmanager, alertManager: alertManager)
                if !newTasks.isEmpty {
                    self.tasks = newTasks
                }
            }.listStyle(.plain)
                .scrollContentBackground(.hidden)
                .background(.white)
        }.frame(maxHeight: .infinity ,alignment: .top).onAppear{
            moveFavoriteToTop()
        }
    }
}

#Preview {
    @Previewable @State var tasks: [ToDoTask] = [
        ToDoTask(
            mainTask: MainTask(
                calendarId: "",
                color: "",
                date: "",
                description: "",
                status: false,
                title: "Task",
            ),
            subTasks: [
                SubTasks(id: UUID() ,title: "To Do", status: false)
            ]
        )
    ]
    TaskListComponent(tasks: $tasks)
}
