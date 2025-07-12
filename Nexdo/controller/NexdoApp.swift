import SwiftUI
import SwiftData

@main
struct NexdoApp: App {    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(for: [Task.self])
        }
    }
}
