//
//  CreateNewTask.swift
//  ToDoListIos
//
//  Created by Abdulkareem Mashabi on 09/11/1447 AH.
//

import SwiftUI

struct CreateNewTask: View {
    @State private var title: String = ""
    @State private var description: String = ""
    @State private var isPresented: Bool = false
    @State private var selectedDate: String = ""
    @EnvironmentObject private var appColors: AppColors
    private var isButtonDisabled: Bool {
        return title.isEmpty
    }
    @State private var color: ColorsToDo = ColorsToDo.red
    
    var body: some View {
        ZStack(alignment: .bottom){
            Image(color.image).resizable()
                .scaledToFill().ignoresSafeArea()
        
  
            VStack {
                TextInput(data: $title, placeholder: localized("task.title") ,error: localized("task.titleRequired"))
                DateInput(selectedDate: $selectedDate, dateIconColor: color.color, placeholder: localized("task.dateOptional"))
                TextInput(data: $description, placeholder: localized("task.description") ,error: localized("task.descriptionRequired"), isTextArea: true)
                
                if !selectedDate.isEmpty {
                        Toggle(isOn: $isPresented) {
                            Text(localized("task.addToCalendar"))
                        }.padding(.vertical, 8)
                }
                
                ButtonComponent {
                    Task {
                        
                    }
                } label: {
                    Text(localized("common.submit"))
                }.formButtonStyle().isButtonDisabled(isButtonDisabled)
            }.padding(12).frame(width: UIScreen.main.bounds.width).background(    RoundedRectangle(cornerRadius: 20)
                .fill(.white)
                .shadow(radius: 6).ignoresSafeArea()).onAppear {
                    color = appColors.getImage()
                }
        }
        
    }
}

#Preview {
    CreateNewTask()
}
