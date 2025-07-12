import SwiftUI
import SwiftData


struct TaskListView: View {
    @Environment(\.modelContext) private var modelContext
    let tasks: [Task]
    @Binding var path: [Task]

    var body: some View {
        List {
            ForEach(tasks) { task in
                Button {
                    path.append(task)
                } label: {
                    TaskRow(task: task, modelContext: modelContext)
                }
                .swipeActions {
                    Button(role: .destructive) {
                        deleteTask(task)
                    } label: {
                        Label("Delete", systemImage: "trash")
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
        modelContext.delete(task)
        try? modelContext.save()
    }
}
