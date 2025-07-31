import SwiftUI
import SwiftData

struct CreateSprintView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var navService: NavigationService
    @EnvironmentObject var sprintService: SprintService

    
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
                    
                    VStack(alignment: .leading, spacing: 12) {
                        Text(LocalizedStringKey("assign_open_tasks"))
                            .font(.title3.bold())
                            .padding(.horizontal)
                        
                        if openTasks.isEmpty {
                            Text(LocalizedStringKey("no_open_tasks_sprint"))
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
                Button(LocalizedStringKey("save")) {
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
        .alert(LocalizedStringKey("error"), isPresented: $showAlert) {
            Button("ok", role: .cancel) { }
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
        let selectedTasks = openTasks.filter { selectedTaskIDs.contains($0.id) }
        let sprint = createSprint(with: selectedTasks)
        do {
            try sprintService.saveSprint(sprint, with: selectedTasks)
            showToast = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                showToast = false
                dismiss()
            }
        } catch SprintError.overlappingDates(let start, let end) {
            let startString = DateUtils.formatDateToString(for: start)
            let endString = DateUtils.formatDateToString(for: end)
            showError(with: "You can't create a Sprint in this Date Range because there is a Sprint from \(startString) to \(endString) already.")
        } catch {
            print("Failed to save sprint: \(error)")
            showError(with: "Failed to save sprint. Please try again.")
        }
    }

    private func showError(with message: String) {
        errorMessage = message
        showAlert = true
    }
    
    private func createSprint(with tasks: [Task]) -> Sprint {
        Sprint(
            startDate: startDate,
            endDate: endDate,
            status: status,
            tasks: tasks
        )
    }
}
