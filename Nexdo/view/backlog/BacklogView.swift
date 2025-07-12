import SwiftUI
import SwiftData

struct BacklogView: View {
    @State private var showCreateTask = false
    @State private var navigationPath: [Task] = []

    static let openRaw = TaskStatus.open.rawValue
    static let plannedRaw = TaskStatus.planned.rawValue

    @Query(
        filter: #Predicate<Task> { task in
            task.status == "open" || task.status == "planned"
        },
        sort: \Task.createdAt,
        order: .reverse
    )
    private var tasks: [Task]

    var body: some View {
        NavigationStack(path: $navigationPath) {
            VStack {
                if tasks.isEmpty {
                    
                    EmptyTaskView()
                } else {
                    TaskListView(tasks: tasks, path: $navigationPath)
                }
                Spacer()
                if navigationPath.isEmpty {
                    CreateTaskButton {
                        showCreateTask = true
                    }
                }
            }
            .sheet(isPresented: $showCreateTask) {
                CreateTaskView()
                    .presentationDetents([.medium, .large])
                    .presentationDragIndicator(.visible)
            }
            .navigationDestination(for: Task.self) { task in
                TaskDetailView(task: task)
            }
            .navigationBarBackButtonHidden(true)
        }
    }
}
