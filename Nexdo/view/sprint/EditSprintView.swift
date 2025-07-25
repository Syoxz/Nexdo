import SwiftUI
import SwiftData

struct EditSprintView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var startDate: Date
    @State private var endDate: Date
    @State private var status: String
    @State private var selectedTaskIDs: Set<UUID> = []
    @State private var showAlert = false
    @State private var errorMessage = ""
    let sprint: Sprint

    @Query(
        filter: Task.openTasks(),
        sort: \Task.createdAt,
        order: .reverse
    )
    private var openTasks: [Task]

    private var currentTasks: [Task] {
        sprint.tasks
    }

    init(sprint: Sprint) {
        self.sprint = sprint
        _startDate = State(initialValue: sprint.startDate)
        _endDate = State(initialValue: sprint.endDate)
        _status = State(initialValue: sprint.status)
        _selectedTaskIDs = State(initialValue: Set(sprint.tasks.map { $0.id }))
    }

    var body: some View {
        VStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    dateSection
                    taskListSection(title: "Currently Assigned Tasks", tasks: currentTasks, emptyMessage: "No currently saved Task for that Sprint")
                    taskListSection(title: "Assign Open Tasks", tasks: openTasks, emptyMessage: "No open tasks available...\nCreate tasks to assign them to this sprint in Backlog.")
                    Spacer()
                }
                .padding(.top)
            }
            .background(Color(.systemGroupedBackground).ignoresSafeArea())
            .navigationTitle("Edit Sprint")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", role: .cancel) {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        editSprint()
                        if !showAlert {
                            dismiss()
                        }
                    }
                    .disabled(startDate >= endDate)
                }
            }
            .alert("Error", isPresented: $showAlert) {
                    Button("OK", role: .cancel) { }
            } message: {
                Text(errorMessage)
            }
        }
    }


    //TODO: Später in einen Service auslagern für beide Views
    private func showError(_ message: String) {
        errorMessage = message
        showAlert = true
    }


    private func fetchExistingSprints() -> [Sprint] {
        let descriptor = FetchDescriptor<Sprint>()
        do {
            return try modelContext.fetch(descriptor)
        } catch {
            print("Failed to fetch sprints: \(error)")
            return []
        }
    }

    private var dateSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Dates")
                .font(.title3.bold())
                .padding(.horizontal)

            Card {
                VStack(spacing: 12) {
                    AutoCloseDatePicker(date: $startDate, label: "Start")
                    Divider()
                    AutoCloseDatePicker(date: $endDate, label: "End")
                }
                .padding()
            }
            .padding(.horizontal)
        }
    }

    private func taskListSection(title: String, tasks: [Task], emptyMessage: String) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.title3.bold())
                .padding(.horizontal)

            if tasks.isEmpty {
                Text(emptyMessage)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding(.horizontal)
            } else {
                LazyVStack(spacing: 10) {
                    ForEach(tasks) { task in
                        MultipleSelectionRow(task: task, isSelected: selectedTaskIDs.contains(task.id)) {
                            toggleSelection(for: task)
                        }
                        .animation(.easeInOut, value: selectedTaskIDs)
                    }
                }
                .padding(.horizontal)
            }
        }
    }

    private func toggleSelection(for task: Task) {
        if selectedTaskIDs.contains(task.id) {
            selectedTaskIDs.remove(task.id)
        } else {
            selectedTaskIDs.insert(task.id)
        }
    }

    private func editSprint() {
        let existingSprints = fetchExistingSprints()

        let overlappingSprints = existingSprints.filter { existing in
            return (sprint.id != existing.id && (startDate <= existing.endDate && endDate >= existing.startDate))
        }
        if let overlap = overlappingSprints.first {
            // Show error message to user
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .medium
            let start = dateFormatter.string(from: overlap.startDate)
            let end = dateFormatter.string(from: overlap.endDate)
            
            showError("You can't create a Sprint in this Date Range because there is a Sprint from \(start) to \(end) already.")
            return
        }
        
        let selectedCurrent = currentTasks.filter { selectedTaskIDs.contains($0.id) }
        let selectedOpen = openTasks.filter { selectedTaskIDs.contains($0.id) }
        let selectedTasks = selectedCurrent + selectedOpen
        
        for task in currentTasks where !selectedTaskIDs.contains(task.id) {
            unassign(task)
        }

        for task in selectedTasks {
            assign(task, to: sprint)
        }
        
        updateSprint(with: selectedTasks)
        do {
            try modelContext.save()
        } catch {
            print("Failed to save sprint: \(error)")
        }
    }

    private func assign(_ task: Task, to sprint: Sprint) {
        if (isTaskDone(task)) {
            task.status = TaskStatus.done.rawValue
        } else {
            task.status = TaskStatus.planned.rawValue
        }
        task.sprint = sprint
    }

    private func unassign(_ task: Task) {
        if (isTaskDone(task)) {
            task.status = TaskStatus.done.rawValue
        } else {
            task.status = TaskStatus.open.rawValue
        }
        task.sprint = nil
    }
    
    private func isTaskDone(_ task: Task) -> Bool {
        return task.status == TaskStatus.done.rawValue
    }

    private func updateSprint(with tasks: [Task]) {
        sprint.startDate = startDate
        sprint.endDate = endDate
        sprint.status = SprintStatus.planned.rawValue
        sprint.tasks = tasks
    }
}
