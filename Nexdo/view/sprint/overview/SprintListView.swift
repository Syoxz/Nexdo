import SwiftUI
import SwiftData

struct SprintListView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    @EnvironmentObject private var navService: NavigationService
    @EnvironmentObject private var sprintService: SprintService

    @State private var currentIndex = 0
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
                    
                    TaskListView(tasks: currentSprint.tasks)
                }
            }
            .navigationTitle(LocalizedStringKey("sprint_overview_title"))
            .onAppear {
                setInitialSprintIndex(sprintService.storedSprints)
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
       if let index = storedSprints.firstIndex(where: {
            $0.startDate <= Date() && $0.endDate >= Date()
        }) {
            currentIndex = index
        } else {
            currentIndex = 0
        }
    }

    private func deleteSprint(_ sprint: Sprint) {
        sprintService.deleteSprint(sprint)
        let numberOfSprints = sprintService.storedSprints.count
        if numberOfSprints == 0 {
            currentIndex = 0
        } else if currentIndex >= numberOfSprints {
            currentIndex = numberOfSprints - 1
        }
    }
}

