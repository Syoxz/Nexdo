import SwiftUI
import SwiftData

struct CreateTaskView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    @State private var taskName = ""
    @State private var taskDescription = ""
    @State private var dueDate = Date()
    @State private var showingDatePicker = false

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("task_name", text: $taskName)
                    TextField("task_description", text: $taskDescription)
                }

                Section {
                    if showingDatePicker {
                        HStack {
                            Image(systemName: "calendar.badge.plus")
                            AutoCloseDatePicker(date: $dueDate, label: "task_due_date")
                        }
                    } else {
                        Button {
                            withAnimation {
                                showingDatePicker = true
                            }
                        } label: {
                            Label("task_due_date", systemImage: "calendar.badge.plus")
                        }
                    }
                }
            }
            .navigationTitle(Text(LocalizedStringKey("task_new")))
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(LocalizedStringKey("cancel")) {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button(LocalizedStringKey("save")) {
                        saveTask()
                    }
                    .disabled(taskName.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }

    private func saveTask() {
        let newTask = Task(
            id: UUID(),
            name: taskName.trimmingCharacters(in: .whitespaces),
            taskDescription: taskDescription.trimmingCharacters(in: .whitespaces),
            status: .open,
            createdAt: Date.now,
            dueDate: showingDatePicker ? dueDate : nil
        )

        modelContext.insert(newTask)
        do {
            try modelContext.save()
            dismiss()
        } catch {
            print("Failed to save task:", error)
        }
    }
}
