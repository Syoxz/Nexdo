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
            self.container = modelContainer
            
            // Initialize SprintService with modelContext from the container
            let service = SprintService(modelContext: modelContainer.mainContext)
            
            // Run startup logic
            service.markExpiredSprintsCompleted()
            
            _navService = StateObject(wrappedValue: NavigationService())
            _sprintService = StateObject(wrappedValue: service)
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

