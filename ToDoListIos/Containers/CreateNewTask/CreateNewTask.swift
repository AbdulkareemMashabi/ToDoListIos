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
    @State private var isPresented: Bool = true
    @State private var selectedDate = Date()
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
                TextInput(data: $title, placeholder: "Title" ,error: "Title is required")
                DateInput(dateIconColor: color.color, placeholder: "Date (Optional)")
                TextInput(data: $description, placeholder: "Description" ,error: "Description is required", isTextArea: true)
                
                ButtonComponent {
                    Task {
                        
                    }
                } label: {
                    Text("Submit")
                }.fontWeight(.bold).foregroundColor(.white)
                    .frame(maxWidth: .infinity, maxHeight: 40)
                    .background(color.color)
                    .cornerRadius(16).disabled(isButtonDisabled).opacity(isButtonDisabled ? 0.5 : 1)
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
