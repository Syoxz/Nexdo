import SwiftUI
import SwiftData

struct TaskDetailView: View {
    @Bindable var task: Task
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var showDatePicker = false

    var body: some View {
        Form {
            Section {
                TextField("Title", text: $task.name)
                    .font(.title2)
                    .padding(.vertical, 4)

                TextField("Description", text: $task.taskDescription, axis: .vertical)
                    .lineLimit(3...6)
                    .padding(.vertical, 4)
            }

            Section {
                if task.dueDate != nil {
                    AutoCloseDatePicker(date: Binding<Date>(
                        get: { task.dueDate ?? Date() },
                        set: { task.dueDate = $0 }
                    ), label: "task_due_date")
                } else {
                    Button {
                        if task.dueDate == nil {
                            task.dueDate = Date()
                        }
                    } label: {
                        Label("Set Due Date", systemImage: "calendar")
                    }
                }
            }

            Section("Created") {
                Text(task.createdAt.formatted(date: .abbreviated, time: .omitted))
                    .foregroundColor(.secondary)
            }

        }
        .navigationTitle("Task Details")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Close") {
                    dismiss()
                }
            }
        }
    }
}
