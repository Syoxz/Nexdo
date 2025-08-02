import SwiftUI

struct ActionButtonsView: View {
    @EnvironmentObject private var navService: NavigationService
    @EnvironmentObject private var sprintService: SprintService

    let sprint: Sprint
    let onDelete: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            Spacer()
            
            switch SprintStatus(rawValue: sprint.status) {
            case .active:
                ActionButton(systemName: "stop.fill", color: .red) {
                    sprintService.updateStatus(.planned, for: sprint)
                }                
            case .planned:
                ActionButton(systemName: "trash.fill", color: .red, action: onDelete)
                ActionButton(systemName: "pencil", color: .gray) {
                    navService.goToEditSprint(sprint)
                }
                ActionButton(systemName: "play.fill", color: .green) {
                    sprintService.updateStatus(.active, for: sprint)
                }
            case .completed:
                ActionButton(systemName: "trash.fill", color: .red, action: onDelete)
            default:
                EmptyView()
            }
        }
    }
    
    private func ActionButton(systemName: String, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.title2)
                .foregroundColor(.white)
                .frame(width: 44, height: 44)
                .background(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(color)
                        .shadow(color: Color.black.opacity(0.2), radius: 6, x: 0, y: 3)
                )
                .contentShape(Rectangle())
        }
    }
}
