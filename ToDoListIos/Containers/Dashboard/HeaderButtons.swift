//
//  HeaderButtons.swift
//  ToDoListIos
//
//  Created by Abdulkareem Mashabi on 07/05/1447 AH.
//

import SwiftUI

struct HeaderButtons: View {
    var body: some View {
            HStack{
                Button {
                    
                } label: {
                    Image(systemName: "globe")
                }
                Spacer()
                Button {
                    
                } label: {
                    Image(systemName: "power")
                }
            }

    }
}

#Preview {
    HeaderButtons()
}
