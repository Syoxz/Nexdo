import SwiftUI

/**
    A view primary for IPad's that displays a confirmation dialog for deleting an item.
 */
struct DeleteConfirmationDialogView<T>: View {
    @Binding var isPresented: Bool
    var item: T?
    var message: LocalizedStringKey
    var onDelete: (T) -> Void

    var body: some View {
        ZStack {
            Color.black.opacity(0.4)
                .edgesIgnoringSafeArea(.all)
                .onTapGesture {
                    isPresented = false
                }

            VStack(spacing: 20) {
                Text(message)
                    .font(.headline)
                    .multilineTextAlignment(.center)
                    .padding()

                HStack(spacing: 20) {
                    Button(LocalizedStringKey("cancel")) {
                        isPresented = false
                    }
                    .frame(minWidth: 80)
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(8)

                    Button(LocalizedStringKey("delete")) {
                        if let item = item {
                            onDelete(item)
                        }
                        isPresented = false
                    }
                    .frame(minWidth: 80)
                    .padding()
                    .background(Color.red)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                }
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(16)
            .shadow(radius: 10)
            .frame(maxWidth: 300)
            .transition(.scale)
            .zIndex(1)
        }
    }
}
