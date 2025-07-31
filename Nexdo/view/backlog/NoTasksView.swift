import SwiftUI


struct NoTasksView: View {
    var body: some View {
        VStack(spacing: 16) {
            Spacer()
            Text("Keine Tasks vorhanden")
                .font(.headline)
                .foregroundColor(.gray)
            Spacer()
        }
    }
}
