//
//  AccountDeletion.swift
//  ToDoListIos
//
//  Created by Abdulkareem Mashabi on 03/02/1448 AH.
//

import SwiftUI

struct AccountDeletion: View {
    @State var email: String = ""
    @State var password: String = ""
    private var isButtonDisabled: Bool {
        return email.isEmpty || password.isEmpty || !isValidEmail(email)
    }
    var body: some View {
        ZStack{
            Image("waves").resizable().ignoresSafeArea()
            VStack(alignment:.leading) {
                Text("Enter your Email and Password to Delete your Account").fontWeight(.bold).font(.title)
                TextInput(data: $email, placeholder: "Email", error: getEmailValidation(email: email))
                TextInput(data: $password, placeholder: "Password", isSecureTextEntry: true, error: getEmptyErrorMessage(fieldName: "password", fieldValue:password))
                ButtonComponent {
                    
                    
                } label: {
                    Text("Delete Account")
                }.formButtonStyle().isButtonDisabled(isButtonDisabled)
            }.frame(maxWidth:.infinity, maxHeight: .infinity, alignment: .top).padding()

        }
        

    }
}

#Preview {
    AccountDeletion()
}
