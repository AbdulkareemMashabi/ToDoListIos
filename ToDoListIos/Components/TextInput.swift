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
    var error: String = ""
    var isTextArea: Bool = false

    var body: some View {
        VStack(alignment: .leading) {
            ZStack(alignment: .leading) {
                if isTextArea {
                    TextEditor(text: $data)
                        .focused($isTextFieldFocus)
                        .padding(.horizontal, 4)
                        .padding(.top, 4)
                        .frame(height: 112)
                        .scrollContentBackground(.hidden)
                        .background(.white)
                        .cornerRadius(16)
                        .shadow(radius: 2)
                        .onChange(of: isTextFieldFocus) {
                            if isTextFieldFocus {
                                hasFocusedBefore = true
                            }
                        }
                        .onChange(of: data) {
                            if let charsLimits, data.count > charsLimits {
                                data = String(data.prefix(charsLimits))
                            }
                        }
                } else if !isShowPassword && isSecureTextEntry {
                    SecureField("", text: $data)
                        .focused($isTextFieldFocus)
                        .padding(.leading, 8)
                        .padding(.top, 8)
                        .frame(maxHeight: 40)
                        .background(.white)
                        .cornerRadius(16)
                        .shadow(radius: 2)
                        .onChange(of: isTextFieldFocus) {
                            if isTextFieldFocus {
                                hasFocusedBefore = true
                            }
                        }
                        .onChange(of: data) {
                            if let charsLimits, data.count > charsLimits {
                                data = String(data.prefix(charsLimits))
                            }
                        }
                } else {
                    TextField("", text: $data)
                        .keyboardType(keyboardType)
                        .focused($isTextFieldFocus)
                        .padding(.horizontal, 8)
                        .padding(.top, 8)
                        .frame(maxHeight: 40)
                        .background(.white)
                        .cornerRadius(16)
                        .shadow(radius: 2)
                        .foregroundColor(.black)
                        .onChange(of: isTextFieldFocus) {
                            if isTextFieldFocus {
                                hasFocusedBefore = true
                            }
                        }
                        .onChange(of: data) {
                            if let charsLimits, data.count > charsLimits {
                                data = String(data.prefix(charsLimits))
                            }
                        }
                }

                Text(placeholder)
                    .offset(y: {
                        if forceToFocused {
                            return isTextArea ? -47 : -13
                        } else {
                            return 0
                        }
                    }())
                    .padding(.leading, 8)
                    .font(forceToFocused ? .caption : .body)
                    .foregroundColor(.gray)
                    .animation(.spring, value: forceToFocused)
                    .allowsHitTesting(false)

                if isSecureTextEntry {
                    HStack {
                        Spacer()
                        Button {
                            isShowPassword.toggle()
                        } label: {
                            Image(systemName: isShowPassword ? "eye" : "eye.slash")
                                .foregroundColor(.cyan)
                        }
                        .padding(.trailing, 8)
                    }
                }
            }.frame(maxWidth: .infinity, maxHeight: isTextArea ? 112 : 40)

            if !error.isEmpty && hasFocusedBefore {
                Text(error)
                    .foregroundColor(.red)
                    .padding(.top, 8)
                    .padding(.horizontal, 4)
            }
        }
    }
}

#Preview {
    @Previewable @State var data: String = ""
    VStack(spacing: 24) {
        TextInput(data: $data, placeholder: "Username")
        TextInput(data: $data, placeholder: "Password", isSecureTextEntry: true)
        TextInput(data: $data, placeholder: "Bio", isTextArea: true)
        TextInput(data: $data, placeholder: "With error", error: "This field is required")
    }
    .padding()
}
