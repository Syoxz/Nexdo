import SwiftUI


struct NoTasksView: View {
    var body: some View {
        VStack(spacing: 16) {
            Spacer()
            Text(LocalizedStringKey("no_open_tasks"))
                .font(.headline)
                .foregroundColor(.gray)
            Spacer()
        }
    }
}
