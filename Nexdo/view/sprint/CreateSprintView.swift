import SwiftUI
import SwiftData

struct CreateSprintView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var startDate: Date = Date()
    @State private var endDate: Date = Date().addingTimeInterval(7 * 24 * 60 * 60)
    @State private var status: SprintStatus = .planned
    @State private var selectedTaskIDs: Set<UUID> = []
    @State private var calendarId: Int = 0

    private static let openRaw = TaskStatus.open.rawValue

    @Query(
        filter: Task.openTasks(),
        sort: \Task.createdAt,
        order: .reverse
    )
    private var openTasks: [Task]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
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

                    VStack(alignment: .leading, spacing: 12) {
                        Text("Assign Open Tasks")
                            .font(.title3.bold())
                            .padding(.horizontal)

                        if openTasks.isEmpty {
                            Text("No open tasks available... \nCreate tasks to assign them to this sprint in Backlog.")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .padding(.horizontal)
                        
                            
                        } else {
                            LazyVStack(spacing: 10) {
                                ForEach(openTasks) { task in
                                    MultipleSelectionRow(task: task, isSelected: selectedTaskIDs.contains(task.id)) {
                                        toggleSelection(for: task)
                                    }
                                    .animation(.easeInOut, value: selectedTaskIDs)
                                }
                            }
                            .padding(.horizontal)
                        }
                    }

                    Spacer()
                }
                .padding(.top)
            }
            .background(Color(.systemGroupedBackground).ignoresSafeArea())
            .navigationTitle("Create Sprint")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", role: .cancel) {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveSprint()
                        dismiss()
                    }
                    .disabled(startDate >= endDate)
                }
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

    private func saveSprint() {
        let selectedTasks = openTasks.filter { selectedTaskIDs.contains($0.id) }
        let sprint = createSprint(with: selectedTasks)

        assignTasks(selectedTasks, to: sprint)

        modelContext.insert(sprint)

        do {
            try modelContext.save()
        } catch {
            print("Failed to save sprint: \(error)")
        }
    }

    private func createSprint(with tasks: [Task]) -> Sprint {
        Sprint(
            startDate: startDate,
            endDate: endDate,
            status: status,
            tasks: tasks
        )
    }

    private func assignTasks(_ tasks: [Task], to sprint: Sprint) {
        for task in tasks {
            task.status = TaskStatus.planned.rawValue
            task.sprint = sprint
        }
    }

}
