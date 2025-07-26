import SwiftUI
import SwiftData

struct SprintDetailView: View {
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
                    HeaderView(sprint: currentSprint,
                               currentIndex: $currentIndex,
                               maxIndex: storedSprints.count - 1)
                    if Calendar.current.isDateInToday(currentSprint.endDate) {
                        Text("Sprint completed on \(formatted(currentSprint.endDate))")
                            .padding()
                    } else {
                        ActionButtonsView(sprint: currentSprint,
                                          onDelete: {
                            sprintToDelete = currentSprint
                            showDeleteDialog = true
                        },
                           onEdit: {
                            navService.goToEditSprint(currentSprint)
                        },
                            onStatusChange: { status in
                            updateStatus(status, for: currentSprint)
                        })
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
                Color.black.opacity(0.4)
                    .edgesIgnoringSafeArea(.all)
                    .onTapGesture {
                        showDeleteDialog = false
                    }

                VStack(spacing: 20) {
                    Text("Are you sure you want to delete this sprint?")
                        .font(.headline)
                        .multilineTextAlignment(.center)
                        .padding()

                    HStack(spacing: 20) {
                        Button("Cancel") {
                            showDeleteDialog = false
                        }
                        .frame(minWidth: 80)
                        .padding()
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(8)

                        Button("Delete") {
                            if let sprint = sprintToDelete {
                                deleteSprint(sprint)
                            }
                            showDeleteDialog = false
                        }
                        .frame(minWidth: 80)
                        .padding()
                        .background(Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                    }
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(16)
                .shadow(radius: 10)
                .frame(maxWidth: 300)
                .transition(.scale)
                .zIndex(1)
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

    private func updateStatus(_ status: SprintStatus, for sprint: Sprint) {
        sprint.status = status.rawValue
        try? modelContext.save()
    }

    private func formatted(_ date: Date) -> String {
        Self.dateFormatter.string(from: date)
    }

    public static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }()
}

private struct HeaderView: View {
    let sprint: Sprint
    @Binding var currentIndex: Int
    let maxIndex: Int

    var body: some View {
        HStack {
            Button(action: { if currentIndex > 0 { currentIndex -= 1 } }) {
                Image(systemName: "chevron.left")
                    .foregroundColor(currentIndex > 0 ? .accentColor : .gray)
            }
            .disabled(currentIndex == 0)

            Spacer()

            Text("\(SprintDetailView.dateFormatter.string(from: sprint.startDate)) - \(SprintDetailView.dateFormatter.string(from: sprint.endDate))")
                .font(.headline)

            Spacer()

            Button(action: { if currentIndex < maxIndex { currentIndex += 1 } }) {
                Image(systemName: "chevron.right")
                    .foregroundColor(currentIndex < maxIndex ? .accentColor : .gray)
            }
            .disabled(currentIndex == maxIndex)
        }
        .padding([.horizontal, .top])
    }
}

private struct ActionButtonsView: View {
    let sprint: Sprint
    let onDelete: () -> Void
    let onEdit: () -> Void
    let onStatusChange: (SprintStatus) -> Void

    var body: some View {
        HStack(spacing: 12) {
            Spacer()

            switch SprintStatus(rawValue: sprint.status) {
            case .active:
                Button("Stop") {
                    onStatusChange(.planned)
                }
                .buttonStyle(.borderedProminent)
                .tint(.red)

            case .planned:
                Button("Delete") { onDelete() }
                    .buttonStyle(.borderedProminent)
                    .tint(.red)

                Button("Edit") { onEdit() }
                    .buttonStyle(.borderedProminent)
                    .tint(.gray)

                Button("Start") { onStatusChange(.active) }
                    .buttonStyle(.borderedProminent)
                    .tint(.green)

            default:
                EmptyView()
            }
        }
    }
}
