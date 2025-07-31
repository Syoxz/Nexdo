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
                    taskListSection(title: LocalizedStringKey("currently_assigned_tasks"), tasks: currentTasks, emptyMessage: LocalizedStringKey("no_currently_assigned_tasks"))
                    taskListSection(title: LocalizedStringKey("assign_open_tasks"), tasks: openTasks, emptyMessage: LocalizedStringKey("no_open_tasks"))
                    Spacer()
                }
                .padding(.top)
            }
            .background(Color(.systemGroupedBackground).ignoresSafeArea())
            .navigationTitle(LocalizedStringKey("edit_sprint_title"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button(LocalizedStringKey("save")) {
                        editSprint()
                        if !showAlert {
                            dismiss()
                        }
                    }
                    .disabled(startDate >= endDate)
                }
            }
            .alert(LocalizedStringKey("error"), isPresented: $showAlert) {
                    Button("ok", role: .cancel) { }
            } message: {
                Text(errorMessage)
            }
        }
    }


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
            Text(LocalizedStringKey("date_range"))
                .font(.title3.bold())
                .padding(.horizontal)

            Card {
                VStack(spacing: 12) {
                    AutoCloseDatePicker(date: $startDate, label: LocalizedStringKey("start"))
                    Divider()
                    AutoCloseDatePicker(date: $endDate, label: LocalizedStringKey("end"))
                }
                .padding()
            }
            .padding(.horizontal)
        }
    }

    private func taskListSection(title: LocalizedStringKey, tasks: [Task], emptyMessage: LocalizedStringKey) -> some View {
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
