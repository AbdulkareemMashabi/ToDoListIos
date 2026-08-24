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
    var isSecureTextEntry: Bool = false
    var keyboardType: UIKeyboardType = .default
    var charsLimits: Int?
    var error: String = ""
    var isTextArea: Bool = false
    var onBlur: (() -> Void)?

    @FocusState private var isTextFieldFocus: Bool
    @State private var hasFocusedBefore: Bool = false
    @State private var isShowPassword: Bool = false

    private var forceToFocused: Bool {
        isTextFieldFocus || !data.isEmpty
    }

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
                        .padding(.trailing, 44)
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
                        .padding(.leading, 8)
                        .padding(.trailing, isSecureTextEntry ? 44 : 8)
                        .padding(.top, 8)
                        .frame(maxHeight: 40)
                        .background(.white)
                        .cornerRadius(16)
                        .shadow(radius: 2)
                        .foregroundColor(.black)
                        .onChange(of: isTextFieldFocus) {
                            if isTextFieldFocus {
                                hasFocusedBefore = true
                            } else if let onBlur {
                                onBlur()
                            }
                        }
                        .onChange(of: data) {
                            if let charsLimits, data.count > charsLimits {
                                data = String(data.prefix(charsLimits))
                            }
                        }
                }

                Text(placeholder)
                    .offset(y: forceToFocused ? (isTextArea ? -47 : -13) : 0)
                    .padding(.leading, 8)
                    .padding(.trailing, isSecureTextEntry ? 44 : 8)
                    .font(forceToFocused ? .caption : .body)
                    .foregroundColor(.gray)
                    .animation(.spring, value: forceToFocused)
                    .allowsHitTesting(false)

                if isSecureTextEntry {
                    Button {
                        isShowPassword.toggle()
                    } label: {
                        Image(systemName: isShowPassword ? "eye" : "eye.slash")
                            .foregroundColor(.cyan)
                    }
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .padding(.trailing, 8)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: isTextArea ? 112 : 40)

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
