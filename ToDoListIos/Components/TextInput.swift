//
//  TextInput.swift
//  ToDoListIos
//
//  Created by Abdulkareem Mashabi on 02/06/1447 AH.
//

import SwiftUI

struct TextInput: View {
    @Binding var data: String
    var placeholder: String = ""
    @FocusState private var isTextFieldFocus: Bool
    @State private var hasFocusedBefore: Bool = false
    var isSecureTextEntry: Bool = false
    var forceToFocused: Bool {
        return isTextFieldFocus || !data.isEmpty
    }
    var keyboardType: UIKeyboardType = .default
    @State private var isShowPassword: Bool = false
    var charsLimits: Int?
    var error: String
    
    var body: some View {
        VStack(alignment:.leading) {
            ZStack(alignment: .leading)  {
                TextField("", text: $data).keyboardType(keyboardType).focused($isTextFieldFocus).padding(.leading,8).padding(.top, 8).frame(maxHeight: 40).background(.white).cornerRadius(16).shadow(radius: 2).foregroundColor(!isShowPassword && isSecureTextEntry ? .clear : .black).onChange(of:isTextFieldFocus){
                    if isTextFieldFocus {
                        hasFocusedBefore = true
                    }
                }.onChange(of:data) {
                    if let charsLimits, data.count > charsLimits {
                        data = String(data.prefix(charsLimits))
                    }
                }
                
                Text(placeholder).offset(y: forceToFocused ? -12: 0).padding(.leading, 8).font(forceToFocused ? .caption : .body).foregroundColor(.gray).animation(.spring, value: isTextFieldFocus)
                
                if !isShowPassword && isSecureTextEntry {
                    Text(String(repeating: "•", count: data.count))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.leading,8).padding(.top, 8).font(.headline).kerning(1)
                }
                
                if isSecureTextEntry {
                    HStack {
                        Spacer()
                        Button {
                            isShowPassword = !isShowPassword
                        } label: {
                            Image(systemName:isShowPassword ? "eye": "eye.slash")
                        }.frame( alignment: .trailing).padding(.trailing, 8)
                    }
                    
                    
                }
                
            }
            
            if !error.isEmpty && (forceToFocused || hasFocusedBefore) {
                Text(error).foregroundColor(.red).contentMargins(.top, 8).padding(4)
            }
        }
        
        
    }
}

#Preview {
    @Previewable @State var data: String = "mdre"
    TextInput(data: $data, placeholder: "klmne", error: "")
}
