//
//  ToastView.swift
//  ToDoListIos
//
//  Created by Abdulkareem Mashabi on 03/12/1447 AH.
//

import SwiftUI

struct ToastView: View {
    let message: String
    
    var body: some View {
        HStack {
            Image("checkMark")
            Text(message)
                .foregroundStyle(.white)
        }.padding(.vertical, 12)
            .padding(.horizontal, 16)
            .background(.green)
            .clipShape(
                RoundedRectangle(cornerRadius: 16)
            )
    }
}

#Preview {
    ToastView(message: "success")
}
