//
//  ButtonComponent.swift
//  ToDoListIos
//
//  Created by Abdulkareem Mashabi on 09/11/1447 AH.
//

import SwiftUI
import Lottie

struct ButtonComponent<LabelView: View>: View {
    var action: () -> Void
     var label: () -> LabelView
    @EnvironmentObject private var loadingManager: LoadingManager
    let filePath = "/Users/abdulkareemmashabi/Desktop/ToDoListIos/ToDoListIos/Resources/Lotties/loadingButton.json"
    @State var isButtonDisabled: Bool = false
    
    var body: some View {
        Button(action: action) {
            if loadingManager.isLoadingButton {
                LottieView(animation: .filepath(filePath))
                    .playbackMode(.playing(.toProgress(1, loopMode: .playOnce)))
                    .scaleEffect(0.6)
            }
            else {
                label().frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            
        }
    }
}

extension View {
    func formButtonStyle() -> some View {
        self
            .fontWeight(.bold)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity, maxHeight: 40)
            .background(.cyan)
            .cornerRadius(16)
    }
}

extension View {
    @ViewBuilder
    func isButtonDisabled(_ disabled: Bool) -> some View {
        if disabled {
            self
                .disabled(true)
                .opacity(0.5)
        } else {
            self
        }
    }
}

#Preview {
    ButtonComponent(action: {
        // Preview action
        print("Button tapped")
    }) {
        Text("Tap me")
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(.blue)
            .foregroundStyle(.white)
            .clipShape(Capsule())
    }
}
