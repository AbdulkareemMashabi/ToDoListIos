import SwiftUI

struct DateInput: View {
    @Binding var selectedDate: String
    var onDateSelected: ((Date) -> Void)?
    var dateIconColor: String = "#808080"
    var placeholder: String = ""
    var error: String = ""

    @State private var pickerDate = Calendar.current.date(
        byAdding: .day,
        value: 1,
        to: Date()
    )!
    @State private var hasFocusedBefore = false
    @State private var showDatePicker = false

    private let tomorrow = Calendar.current.date(
        byAdding: .day,
        value: 1,
        to: Calendar.current.startOfDay(for: Date())
    )!

    private var forceToFocused: Bool {
        showDatePicker || !selectedDate.isEmpty
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
                if !selectedDate.isEmpty {
                    Text(selectedDate)
                        .padding(.horizontal, 8)
                        .offset(y: 4)
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

                Image("calendar")
                    .renderingMode(.template)
                    .foregroundStyle(Color(hex: dateIconColor))
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .padding(8)

                // Transparent tap target covering the whole field
                Color.clear
                    .contentShape(Rectangle())
                    .onTapGesture {
                        hasFocusedBefore = true
                        showDatePicker = true
                    }
            }
            .frame(height: 40)
            .sheet(isPresented: $showDatePicker) {
                VStack {
                    DatePicker(
                        localized("common.selectDate"),
                        selection: $pickerDate,
                        in: tomorrow...,
                        displayedComponents: .date
                    )
                    .datePickerStyle(.graphical)
                    .padding()

                    Button(localized("common.done")) {
                        selectedDate = pickerDate.formatted(date: .numeric, time: .omitted)
                        onDateSelected?(pickerDate)
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
    @Previewable @State var selectedDate: String = ""
    DateInput(selectedDate: $selectedDate, placeholder: "Select date", error: "Required")
}
