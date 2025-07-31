import SwiftData
import SwiftUI

class SprintService : ObservableObject {
    private let modelContext: ModelContext
    
    @Published var sprints: [Sprint] = []
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        self.sprints = getSprints()
    }
    
    public func markExpiredSprintsCompleted() {
        let completed = SprintStatus.completed.rawValue
        let descriptor = FetchDescriptor<Sprint>(predicate: Sprint.expiredSprints())
        do {
            let expiredSprints = try modelContext.fetch(descriptor)
            for sprint in expiredSprints {
                sprint.status = completed
            }
            try modelContext.save()
        } catch {
            print("Error updating expired sprints: \(error)")
        }
    }
    
    public func updateStatus(_ status: SprintStatus, for sprint: Sprint) {
        sprint.status = status.rawValue
        try? modelContext.save()
    }
    
    private func getSprints() -> [Sprint] {
        let descriptor = FetchDescriptor<Sprint>(
            sortBy: [SortDescriptor(\.startDate, order: .forward)]
        )
        do {
            return try modelContext.fetch(descriptor)
        } catch {
            print("Failed to fetch sprints: \(error)")
            return []
        }
    }
    
    public func getCurrentSprint() -> Sprint? {
        return sprints.first(where: {
            $0.startDate <= Date() && $0.endDate >= Date()
        })
    }

}
