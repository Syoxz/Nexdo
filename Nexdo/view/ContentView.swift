import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 0
    @EnvironmentObject private var navService: NavigationService

    var body: some View {
        NavigationStack(path: $navService.path) {
            TabView(selection: $selectedTab) {
                BacklogView()
                    .tabItem {
                        Image(systemName: "list.bullet.rectangle")
                        Text("Backlog")
                    }
                    .tag(1)

                SprintDashboardView()
                    .tabItem {
                        Image(systemName: "timer")
                        Text("Sprint")
                    }
                    .tag(2)
            }
            .accentColor(.blue)
            .navigationDestination(for: Route.self) { route in
                switch route {
                case .createSprint:
                    CreateSprintView()
                case .sprintList:
                    SprintDetailView()
                case .sprintEdit(let sprint):
                    EditSprintView(sprint: sprint)
                case .sprintConfig:
                    SprintConfigView()
                case .taskDetail(let task):
                    TaskDetailView(task: task)
                }
            }
        }
    }
}

