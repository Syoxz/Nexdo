import SwiftUI

struct SprintButton: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void

    @State private var isPressed = false

    var body: some View {
        Button(action: {
            withAnimation(.easeInOut(duration: 0.15)) {
                isPressed = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                isPressed = false
                action()
            }
        }) {
            VStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundColor(.white)

                Text(title)
                    .font(.footnote)
                    .fontWeight(.medium)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.white)
            }
            .padding()
            .frame(width: 90, height: 90)
            .background(color)
            .cornerRadius(16)
            .shadow(color: color.opacity(0.25), radius: isPressed ? 2 : 6, x: 0, y: isPressed ? 1 : 4)
            .scaleEffect(isPressed ? 0.97 : 1.0)
            .animation(.easeOut(duration: 0.2), value: isPressed)
        }
        .buttonStyle(.plain)
    }
}
