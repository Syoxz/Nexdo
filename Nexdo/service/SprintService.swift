import SwiftData
import SwiftUI

class SprintService : ObservableObject {
    private let modelContext: ModelContext
    
    @Published var storedSprints: [Sprint] = []
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        self.storedSprints = getSprints()
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
    
    public func saveSprint(_ newSprint: Sprint, with selectedTasks: [Task]) throws {
        
        let overlappingSprints = storedSprints.filter { existing in
            return (newSprint.startDate <= existing.endDate && newSprint.endDate >= existing.startDate)
        }
        
        if let overlap = overlappingSprints.first {
            throw SprintError.overlappingDates(start: overlap.startDate, end: overlap.endDate)
        }
        
        assignTasks(selectedTasks, to: newSprint)
        modelContext.insert(newSprint)
        storedSprints.append(newSprint)
        try modelContext.save()
    }

    private func assignTasks(_ tasks: [Task], to sprint: Sprint) {
        for task in tasks {
            task.status = TaskStatus.planned.rawValue
            task.sprint = sprint
        }
    }
    
    public func deleteSprint(_ sprint: Sprint) {
        do {
            sprint.tasks.forEach { $0.status = TaskStatus.open.rawValue }
            if let index = storedSprints.firstIndex(where: { $0.id == sprint.id }) {
                storedSprints.remove(at: index)
            }
            modelContext.delete(sprint)
            try modelContext.save()

        }catch {
            print("Failed to delete sprint: \(error)")
        }
    
    }

    
    public func getCurrentSprint() -> Sprint? {
        return storedSprints.first(where: {
            $0.startDate <= Date() && $0.endDate >= Date()
        })
    }

}
