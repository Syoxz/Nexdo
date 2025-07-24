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
    @State private var showAlert = false
    @State private var errorMessage = ""


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

    private func toggleSelection(for task: Task) {
        if selectedTaskIDs.contains(task.id) {
            selectedTaskIDs.remove(task.id)
        } else {
            selectedTaskIDs.insert(task.id)
        }
    }

    private func saveSprint() {
        let existingSprints = fetchExistingSprints()

        // Check for existing sprints with overlapping date range
        let overlappingSprints = existingSprints.filter { existing in
            return (startDate <= existing.endDate && endDate >= existing.startDate)
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
