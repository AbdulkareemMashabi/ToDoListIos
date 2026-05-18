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
    @ViewBuilder var label: () -> LabelView
    @EnvironmentObject private var loadingManager: LoadingManager
    let filePath = "/Users/abdulkareemmashabi/Desktop/ToDoListIos/ToDoListIos/Lotties/loadingButton.json"
    
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
