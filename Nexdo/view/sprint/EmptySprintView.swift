import SwiftUI

struct EmptySprintView: View {
    @EnvironmentObject private var navService: NavigationService

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            Image(systemName: "calendar.badge.exclamationmark")
                .resizable()
                .scaledToFit()
                .frame(width: 80, height: 80)
                .foregroundColor(.accentColor.opacity(0.6))

            VStack(spacing: 8) {
                Text(LocalizedStringKey("no_sprints"))
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)

                Text(LocalizedStringKey("no_sprints_create_sprint)"))
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }

         
            Button(action: {
                navService.goToCreateSprint()
            }) {
                Label(LocalizedStringKey("create_sprint"), systemImage: "plus")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.accentColor)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                    .shadow(color: Color.accentColor.opacity(0.3), radius: 4, x: 0, y: 2)
            }
            .padding(.horizontal, 40)

            Spacer()
        }
        .padding()
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
    }
}
