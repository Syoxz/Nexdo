import SwiftUI

struct HeaderView: View {
    @Binding var currentIndex: Int

    let sprint: Sprint
    let maxIndex: Int

    var body: some View {
        HStack {
            Button(action: { if currentIndex > 0 { currentIndex -= 1 } }) {
                Image(systemName: "chevron.left")
                    .foregroundColor(currentIndex > 0 ? .accentColor : .gray)
            }
            .disabled(currentIndex == 0)

            Spacer()

            Text("\(DateUtils.formatDateToString(for: sprint.startDate)) - \(DateUtils.formatDateToString(for: sprint.endDate))")
                .font(.headline)

            Spacer()

            Button(action: { if currentIndex < maxIndex { currentIndex += 1 } }) {
                Image(systemName: "chevron.right")
                    .foregroundColor(currentIndex < maxIndex ? .accentColor : .gray)
            }
            .disabled(currentIndex == maxIndex)
        }
        .padding([.horizontal, .top])
    }
}
