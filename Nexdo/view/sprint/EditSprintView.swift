import SwiftUI
import SwiftData

struct EditSprintView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var startDate: Date
    @State private var endDate: Date
    @State private var status: String
    @State private var selectedTaskIDs: Set<UUID> = []

    let sprint: Sprint

    // Open Tasks Query
    @Query(
        filter: Task.openTasks(),
        sort: \Task.createdAt,
        order: .reverse
    )
    private var openTasks: [Task]

    // Computed list of tasks already in the sprint
    private var currentTasks: [Task] {
        sprint.tasks
    }

    // MARK: - Init
    init(sprint: Sprint) {
        self.sprint = sprint
        _startDate = State(initialValue: sprint.startDate)
        _endDate = State(initialValue: sprint.endDate)
        _status = State(initialValue: sprint.status)
        _selectedTaskIDs = State(initialValue: Set(sprint.tasks.map { $0.id }))
    }

    // MARK: - Body
    var body: some View {
        NavigationStack {
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
                        dismiss()
                    }
                    .disabled(startDate >= endDate)
                }
            }
        }
    }

    // MARK: - View Sections

    private var dateSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Dates")
                .font(.title3.bold())
                .padding(.horizontal)

            Card {
                VStack(spacing: 12) {
                    DatePicker("Start", selection: $startDate, displayedComponents: .date)
                    Divider()
                    DatePicker("End", selection: $endDate, displayedComponents: .date)
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

    // MARK: - Actions

    private func toggleSelection(for task: Task) {
        if selectedTaskIDs.contains(task.id) {
            selectedTaskIDs.remove(task.id)
        } else {
            selectedTaskIDs.insert(task.id)
        }
    }

    private func editSprint() {
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
        task.status = TaskStatus.planned.rawValue
        task.sprint = sprint
    }

    private func unassign(_ task: Task) {
        task.status = TaskStatus.open.rawValue
        task.sprint = nil
    }

    private func updateSprint(with tasks: [Task]) {
        sprint.startDate = startDate
        sprint.endDate = endDate
        sprint.status = SprintStatus.planned.rawValue
        sprint.tasks = tasks
    }
}
