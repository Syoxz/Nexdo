import SwiftUI
import SwiftData

struct SprintListView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var navService: NavigationService
    @Environment(\.horizontalSizeClass) var horizontalSizeClass

    @Query(sort: \Sprint.startDate, order: .forward)
    private var storedSprints: [Sprint]

    @State private var currentIndex = 0
    @State private var showDeleteDialog = false
    @State private var sprintToDelete: Sprint?

    var body: some View {
        ZStack {
            VStack {
                if storedSprints.isEmpty {
                    EmptySprintView()
                } else {
                    let currentSprint = storedSprints[currentIndex]
                    HeaderView(currentIndex: $currentIndex,
                               sprint: currentSprint,
                               maxIndex: storedSprints.count - 1)
                    ActionButtonsView(sprint: currentSprint,
                        onDelete: {
                            sprintToDelete = currentSprint
                            showDeleteDialog = true
                        })
                    .padding()
                    
                    
                    if currentSprint.status == SprintStatus.completed.rawValue {
                        Text("Sprint completed on \(DateUtils.formatDateToString(for: currentSprint.endDate))")
                            .padding()
                    }
                   

                    Text("Tasks")
                        .font(.title2)
                        .bold()
                        .padding(.horizontal)
                    
                    TaskListView(tasks: currentSprint.tasks)
                }
            }
            .navigationTitle(LocalizedStringKey("sprint_overview_title"))
            .onAppear(perform: setInitialSprintIndex)
            .background(Color(.systemGroupedBackground))
            .confirmationDialog(
                "Are you sure you want to delete this sprint?",
                isPresented: Binding(
                    get: { showDeleteDialog && horizontalSizeClass == .compact },
                    set: { showDeleteDialog = $0 }
                ),
                titleVisibility: .visible
            ) {
                Button("Delete", role: .destructive) {
                    if let sprint = sprintToDelete {
                        deleteSprint(sprint)
                    }
                }
                Button(LocalizedStringKey("cancel"), role: .cancel) {}
            }

            if showDeleteDialog && horizontalSizeClass == .regular {
                DeleteConfirmationDialogView<Sprint>(
                    isPresented: $showDeleteDialog,
                    item: sprintToDelete,
                    message: LocalizedStringKey("delete_sprint"),
                    onDelete: { sprint in
                        deleteSprint(sprint)
                    }
                )

            }
        }
        .animation(.easeInOut, value: showDeleteDialog)
    }

    private func setInitialSprintIndex() {
       if let index = storedSprints.firstIndex(where: {
            $0.startDate <= Date() && $0.endDate >= Date()
        }) {
            currentIndex = index
        } else {
            currentIndex = 0
        }
    }

    private func deleteSprint(_ sprint: Sprint) {
        sprint.tasks.forEach { $0.status = TaskStatus.open.rawValue }
        modelContext.delete(sprint)

        do {
            try modelContext.save()
            let updatedCount = storedSprints.count
            if  updatedCount == 0 {
                currentIndex = 0
            } else if currentIndex >= updatedCount {
                currentIndex = updatedCount - 1
            }
        } catch {
            print("Failed to delete sprint: \(error)")
        }
    }


}

