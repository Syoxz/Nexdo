import SwiftUI
import SwiftData

struct BacklogView: View {
    @State private var showCreateTask = false
    @EnvironmentObject var navService: NavigationService

    private static let openRaw = TaskStatus.open.rawValue
    private static let plannedRaw = TaskStatus.planned.rawValue

    @Query(
        filter: #Predicate<Task> { task in
            task.status == openRaw
        },
        sort: \Task.createdAt,
        order: .reverse
    )
    private var tasks: [Task]

    var body: some View {
        VStack() {
            VStack {
                if tasks.isEmpty {
                    EmptyTaskView()
                } else {
                    TaskListView(tasks: tasks)
                }
                Spacer()
                if navService.path.isEmpty {
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
            .navigationBarBackButtonHidden(true)
        }
    }
}
