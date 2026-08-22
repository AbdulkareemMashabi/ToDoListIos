import SwiftUI

struct CustomToolbar: ViewModifier {
    let title: String
    var leftButtons: [AnyView] = []
    var rightButtons: [AnyView] = []

    func body(content: Content) -> some View {
        content
            .toolbar {
                if !leftButtons.isEmpty {
                    ToolbarItem(placement: .navigationBarLeading) {
                        HStack(spacing: 16) {
                            ForEach(leftButtons.indices, id: \.self) { leftButtons[$0] }
                        }
                    }
                }

                ToolbarItem(placement: .principal) {
                    Text(title).font(.headline)
                }

                if !rightButtons.isEmpty {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        HStack(spacing: 16) {
                            ForEach(rightButtons.indices, id: \.self) { rightButtons[$0] }
                        }
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
    }
}

extension View {
    public func customToolbar(
        title: String,
        leftButtons: [AnyView] = [],
        rightButtons: [AnyView] = []
    ) -> some View {
        modifier(CustomToolbar(
            title: title,
            leftButtons: leftButtons,
            rightButtons: rightButtons
        ))
    }
}
