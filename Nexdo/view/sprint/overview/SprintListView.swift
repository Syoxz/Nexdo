import SwiftUI
import SwiftData

struct SprintListView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    @EnvironmentObject private var navService: NavigationService
    @EnvironmentObject private var sprintService: SprintService

    @State private var currentIndex = 0
    @State private var hasAppeared = false
    @State private var showDeleteDialog = false
    @State private var sprintToDelete: Sprint?
    
    var body: some View {
        ZStack {
            VStack {
                if sprintService.storedSprints.isEmpty {
                    EmptySprintView()
                } else {
                    let currentSprint = sprintService.storedSprints[currentIndex]
                    HeaderView(currentIndex: $currentIndex,
                               sprint: currentSprint,
                               maxIndex: sprintService.storedSprints.count - 1)
                    ActionButtonsView(sprint: currentSprint,
                        onDelete: {
                            sprintToDelete = currentSprint
                            showDeleteDialog = true
                        })
                    .padding()
                    
                    
                    if currentSprint.status == SprintStatus.completed.rawValue {
                        Text(LocalizedStringKey("sprint_completed_on \(DateUtils.formatDateToString(for: currentSprint.endDate))"))
                            .padding()
                    }
                   

                    Text(LocalizedStringKey("tasks"))
                        .font(.title2)
                        .bold()
                        .padding(.horizontal)
                    if currentSprint.tasks.isEmpty {
                        NoTasksView()
                    } else {
                        TaskListView(tasks: currentSprint.tasks.sorted {
                            $0.createdAt < $1.createdAt
                        })
                    }
                    
                }
            }
            .navigationTitle(LocalizedStringKey("sprint_overview_title"))
            .onAppear {
                if (!hasAppeared) {
                    setInitialSprintIndex(sprintService.storedSprints)
                    hasAppeared = true
                }
            }
            .background(Color(.systemGroupedBackground))
            .confirmationDialog(
                LocalizedStringKey("confirmation_delete_sprint"),
                isPresented: Binding(
                    get: { showDeleteDialog && horizontalSizeClass == .compact },
                    set: { showDeleteDialog = $0 }
                ),
                titleVisibility: .visible
            ) {
                Button(LocalizedStringKey("delete"), role: .destructive) {
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
                    message: LocalizedStringKey("confirmation_delete_sprint"),
                    onDelete: { sprint in
                        deleteSprint(sprint)
                    }
                )

            }
        }
        .animation(.easeInOut, value: showDeleteDialog)
    }

    private func setInitialSprintIndex(_ storedSprints: [Sprint]) {
        if let currentSprint = sprintService.getCurrentSprint(),
           let index = storedSprints.firstIndex(of: currentSprint) {
            currentIndex = index
        }
    }

    private func deleteSprint(_ sprint: Sprint) {
        do {
            try sprintService.deleteSprint(sprint)
            let numberOfSprints = sprintService.storedSprints.count
            if numberOfSprints == 0 {
                currentIndex = 0
            } else if currentIndex >= numberOfSprints {
                currentIndex = numberOfSprints - 1
            }
        } catch {
            print("Failed to delete sprint: \(error)")
        }
    }
}

