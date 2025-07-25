import SwiftUI
import SwiftData

@main
struct NexdoApp: App {
    @StateObject private var navService = NavigationService()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(for: [Task.self, Sprint.self])
                .environmentObject(navService)
        }
    }
}