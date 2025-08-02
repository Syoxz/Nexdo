import SwiftUI
import SwiftData


struct TaskListView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var navService: NavigationService

    let tasks: [Task]

    var body: some View {
        List {
            ForEach(tasks) { task in
                Button {
                    navService.goToTaskDetail(task)
                } label: {
                    TaskRow(task: task, modelContext: modelContext)
                }
                .swipeActions {
                    Button(role: .destructive) {
                        deleteTask(task)
                    } label: {
                        Label(LocalizedStringKey("delete"), systemImage: "trash")
                    }
                }
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)
            }
        }
        .listStyle(.plain)
        .background(Color(UIColor.systemGroupedBackground))
    }

    private func deleteTask(_ task: Task) {
        do {
            modelContext.delete(task)
            try modelContext.save()
        } catch {
            print("Error deleting task: \(error)")
        }
    }
}
