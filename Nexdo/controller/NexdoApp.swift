import SwiftUI
import SwiftData

@main
struct NexdoApp: App {
    @StateObject private var navService: NavigationService
    @StateObject private var sprintService: SprintService
    @State private var container: ModelContainer

    init() {
        do {
            let modelContainer = try ModelContainer(for: Sprint.self, Task.self)
            let sprintService = SprintService(modelContext: modelContainer.mainContext)
            let navService = NavigationService()
            
            do {
                try sprintService.markExpiredSprintsCompleted()
            } catch {
                print("Error marking expired sprints as completed: \(error)")
            }

            self._navService = StateObject(wrappedValue: navService)
            self._sprintService = StateObject(wrappedValue: sprintService)
            self._container = State(initialValue: modelContainer)
        } catch {
            fatalError("Failed to initialize ModelContainer: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(container)
                .environmentObject(navService)
                .environmentObject(sprintService)
        }
    }
}
