import SwiftUI
import SwiftData

struct BacklogView: View {
    @State private var showCreateTask = false
    @EnvironmentObject var navService: NavigationService

    private static let openRaw = TaskStatus.open.rawValue
    private static let plannedRaw = TaskStatus.planned.rawValue

    @Query(
        filter: Task.openTasks(),
        sort: \Task.createdAt,
        order: .reverse
    )
    private var tasks: [Task]

    var body: some View {
        VStack() {
            VStack {
                if tasks.isEmpty {
                    NoTasksView()
                } else {
                    TaskListView(tasks: tasks)
                }
                Spacer()
                if navService.path.isEmpty {
                    Button(action: {
                        showCreateTask = true
                    }) {
                        HStack {
                            Image(systemName: "plus")
                            Text("task_add")
                        }
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.accentColor)
                        .foregroundColor(.white)
                        .cornerRadius(16)
                        .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 2)
                        .padding(.horizontal)
                    }
                    .padding(.bottom, 30)
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
