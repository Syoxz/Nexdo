import SwiftUI

struct ToastView: View {
    let message: LocalizedStringKey
    
    var body: some View {
        Text(message)
            .font(.headline)
            .multilineTextAlignment(.center)
            .padding(.vertical, 16)
            .padding(.horizontal, 32)
            .background(Color.green.opacity(0.95))
            .foregroundColor(.white)
            .cornerRadius(16)
            .shadow(radius: 10)
            .padding(.bottom, 40)
    }
}
