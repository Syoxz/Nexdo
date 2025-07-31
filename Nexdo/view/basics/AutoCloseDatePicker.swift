import SwiftUI
/**
    DatePicker Menu closes automatically after a user picked a date
 */
struct AutoCloseDatePicker : View {
    @State private var calendarId: Int = 0
    @Binding var date: Date
    let label: LocalizedStringKey

    var body: some View {
        DatePicker(label, selection: $date, displayedComponents: .date)
            .id(calendarId)
            .onChange(of: date) {
              calendarId += 1
            }
    }
}
