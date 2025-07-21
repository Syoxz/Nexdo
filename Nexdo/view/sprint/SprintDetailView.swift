import SwiftUI
import SwiftData

struct SprintDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var navigationPath: [Task] = []

    @Query(sort: \Sprint.startDate, order: .forward)
    private var storedSprints: [Sprint]

    @State private var currentIndex: Int = 0


    var body: some View {
        NavigationStack {
            if storedSprints.isEmpty {
               EmptySprintView()
            } else {
                let currentSprint = storedSprints[currentIndex]
                header(for: currentSprint)
                if currentSprint.endDate == Date() {
                    Text ("Sprint completed on \(formatted(currentSprint.endDate))")
                } else {
                    actionButtons(for: currentSprint)
                }

                Text("Tasks")
                    .font(.title2)
                    .bold()
                    .padding(.horizontal)
                
                TaskListView(tasks: currentSprint.tasks, path: $navigationPath)
            }
        }
        .background(Color(.systemGroupedBackground))
    }

    private func header(for sprint: Sprint) -> some View {
        HStack {
            Button(action: {
                if currentIndex > 0 { currentIndex -= 1 }
            }) {
                Image(systemName: "chevron.left")
                    .foregroundColor(currentIndex > 0 ? .accentColor : .gray)
            }
            .disabled(currentIndex == 0)

            Spacer()
            Text("\(formatted(sprint.startDate)) - \(formatted(sprint.endDate))")
                .font(.headline)
            Spacer()

            Button(action: {
                if currentIndex < storedSprints.count - 1 { currentIndex += 1 }
            }) {
                Image(systemName: "chevron.right")
                    .foregroundColor(currentIndex < storedSprints.count - 1 ? .accentColor : .gray)
            }
            .disabled(currentIndex == storedSprints.count - 1)
        }
        .padding(.horizontal)
        .padding(.top)
    }

    private func actionButtons(for sprint: Sprint) -> some View {
        HStack {
            Spacer()
            if sprint.status == SprintStatus.active.rawValue {
                Button("Stop") {
                    updateStatus(.planned, for: sprint)
                }
                .buttonStyle(.borderedProminent)
                .tint(.red)
            } else if sprint.status == SprintStatus.planned.rawValue {
                NavigationLink(destination: EditSprintView(sprint: sprint)) {
                    Text("Edit")
                }
                .buttonStyle(.borderedProminent)
                .tint(.gray)
                Button("Start") {
                    updateStatus(.active, for: sprint)
                }
                .buttonStyle(.borderedProminent)
                .tint(.green)
            }
        }
        .padding(.horizontal)
    }

    private func updateStatus(_ status: SprintStatus, for sprint: Sprint) {
        sprint.status = status.rawValue
        try? modelContext.save()
    }

    private func formatted(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}
