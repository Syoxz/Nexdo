import SwiftUI
import SwiftData

struct CreateSprintView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var navService: NavigationService

    @State private var startDate: Date = Date()
    @State private var endDate: Date = Date().addingTimeInterval(7 * 24 * 60 * 60)
    @State private var status: SprintStatus = .planned
    @State private var selectedTaskIDs: Set<UUID> = []
    @State private var calendarId: Int = 0
    @State private var showAlert = false
    @State private var errorMessage = ""
    @State private var showToast = false

    private static let openRaw = TaskStatus.open.rawValue

    @Query(
        filter: Task.openTasks(),
        sort: \Task.createdAt,
        order: .reverse
    )
    private var openTasks: [Task]

    var body: some View {
        VStack {
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
                }
                .padding(.top)
            }
        }
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
        .navigationTitle(LocalizedStringKey("sprint_create_title"))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Save") {
                    saveSprint()
                }
                .disabled(startDate >= endDate)
            }
        }
        .overlay (
            Group {
                if showToast {
                    ToastView(message: LocalizedStringKey("create_sprint_success"))
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                        .animation(.easeInOut, value: showToast)
                }
            },
            alignment: .top
        )
        .alert("Error", isPresented: $showAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage)
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

        // Check for overlapping sprints
        let overlappingSprints = existingSprints.filter { existing in
            return (startDate <= existing.endDate && endDate >= existing.startDate)
        }

        if let overlap = overlappingSprints.first {
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            let start = formatter.string(from: overlap.startDate)
            let end = formatter.string(from: overlap.endDate)

            showError("You can't create a Sprint in this Date Range because there is a Sprint from \(start) to \(end) already.")
            return
        }

        let selectedTasks = openTasks.filter { selectedTaskIDs.contains($0.id) }
        let sprint = createSprint(with: selectedTasks)
        assignTasks(selectedTasks, to: sprint)

        modelContext.insert(sprint)

        do {
            try modelContext.save()
            
            showToast = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                showToast = false
                dismiss()
            }
        } catch {
            print("Failed to save sprint: \(error)")
            showError("Failed to save sprint. Please try again.")
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
