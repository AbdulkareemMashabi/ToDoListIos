import SwiftUI

struct DateInput: View {
    @State private var selectedDate = Date()
    @State private var dateString = ""
    @State private var hasFocusedBefore = false
    @State private var showDatePicker = false
    var dateIconColor: Color = .red

    var placeholder: String = ""
    var error: String = ""

    var forceToFocused: Bool {
        showDatePicker || !dateString.isEmpty
    }

    var body: some View {
        VStack(alignment: .leading) {
            ZStack(alignment: .leading) {
                // Styled field background
                RoundedRectangle(cornerRadius: 16)
                    .fill(.white)
                    .shadow(radius: 2)
                    .frame(maxWidth: .infinity, maxHeight: 40)

                // Date value text
                if !dateString.isEmpty {
                    Text(dateString)
                        .padding(.horizontal, 8)
                        .allowsHitTesting(false)
                }

                // Floating placeholder
                Text(placeholder)
                    .offset(y: forceToFocused ? -13 : 0)
                    .padding(.leading, 8)
                    .font(forceToFocused ? .caption : .body)
                    .foregroundColor(.gray)
                    .animation(.spring, value: forceToFocused)
                    .allowsHitTesting(false)
                
                Image("calendar").renderingMode(.template).foregroundStyle(dateIconColor).frame(maxWidth: .infinity, alignment: .trailing).padding(8)

                // Transparent tap target covering the whole field
                Color.clear
                    .contentShape(Rectangle())
                    .onTapGesture {
                        hasFocusedBefore = true
                        showDatePicker = true
                    }
                

            }
            .frame(height: 40)
            // Sheet with DatePicker
            .sheet(isPresented: $showDatePicker) {
                VStack {
                    DatePicker(
                        localized("common.selectDate"),
                        selection: $selectedDate,
                        displayedComponents: .date
                    )
                    .datePickerStyle(.graphical)
                    .padding()

                    Button(localized("common.done")) {
                        dateString = selectedDate.formatted(date: .numeric, time: .omitted)
                        showDatePicker = false
                    }
                    .buttonStyle(.borderedProminent)
                    .padding(.bottom)
                }
                .presentationDetents([.medium])
            }

            if !error.isEmpty && hasFocusedBefore {
                Text(error)
                    .foregroundColor(.red)
                    .font(.caption)
                    .padding(.leading, 4)
                    .padding(.top, 4)
            }
        }
    }
}

#Preview {
    DateInput(placeholder: "Select date", error: "Required")
}
