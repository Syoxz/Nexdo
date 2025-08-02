import SwiftUI
import SwiftData

struct EditSprintView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var sprintService: SprintService

    @State private var startDate: Date
    @State private var endDate: Date
    @State private var status: String
    @State private var selectedTaskIDs: Set<UUID> = []
    @State private var showAlert = false
    @State private var errorMessage: LocalizedStringKey = ""
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
        let selectedCurrent = currentTasks.filter { selectedTaskIDs.contains($0.id) }
        let selectedOpen = openTasks.filter { selectedTaskIDs.contains($0.id) }
        let selectedTasks = selectedCurrent + selectedOpen
        
        do {
            try sprintService.editSprint(for: sprint, with: selectedTasks, with: selectedTaskIDs, with: startDate, with: endDate)
        } catch SprintError.overlappingDates(let start, let end) {
            let startString = DateUtils.formatDateToString(for: start)
            let endString = DateUtils.formatDateToString(for: end)
            showError(with: LocalizedStringKey("sprint_overlapping_from \(startString) to \(endString)"))
        } catch {
            print("Failed to save sprint: \(error)")
        }
    }
    
    private func showError(with message: LocalizedStringKey) {
        errorMessage = message
        showAlert = true
    }
}
