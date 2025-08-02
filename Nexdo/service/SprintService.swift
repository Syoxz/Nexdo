import SwiftData
import SwiftUI

class SprintService : ObservableObject {
    private let modelContext: ModelContext
    
    @Published var storedSprints: [Sprint] = []
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        self.storedSprints = loadSprints()
    }
    
    public func markExpiredSprintsCompleted() throws {
        let completed = SprintStatus.completed.rawValue
        let descriptor = FetchDescriptor<Sprint>(predicate: Sprint.expiredSprints())
        let expiredSprints = try modelContext.fetch(descriptor)
        for sprint in expiredSprints {
            sprint.status = completed
        }
        try modelContext.save()
    }
    
    public func updateStatus(_ status: SprintStatus, for sprint: Sprint) {
        sprint.status = status.rawValue
        try? modelContext.save()
    }
    
    private func loadSprints() -> [Sprint] {
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
        try modelContext.save()
        
        // Reload sprints after saving (to reflect order)
        storedSprints = loadSprints()
    }
    
    public func editSprint(for sprint: Sprint, with selectedTasks: [Task], with selectedTaskIDs: Set<UUID>, with newStartDate: Date, with newEndDate: Date) throws {
        let currentTasks = sprint.tasks
        let overlappingSprints = storedSprints.filter { existing in
            return (sprint.id != existing.id && (newStartDate <= existing.endDate && newEndDate >= existing.startDate))
        }
        
        if let overlap = overlappingSprints.first {
            throw SprintError.overlappingDates(start: overlap.startDate, end: overlap.endDate)
        }
                
        for task in currentTasks where !selectedTaskIDs.contains(task.id) {
            unassignFromSprint(task)
        }

        for task in selectedTasks {
            assign(task, to: sprint)
        }
        
        updateSprint(sprint, with: selectedTasks, with: newStartDate, with: newEndDate)
        try modelContext.save()
        
    }
    
    private func assign(_ task: Task, to sprint: Sprint) {
        if (isTaskDone(task)) {
            task.status = TaskStatus.done.rawValue
        } else {
            task.status = TaskStatus.planned.rawValue
        }
        task.sprint = sprint
    }

    private func unassignFromSprint(_ task: Task) {
        if (isTaskDone(task)) {
            task.status = TaskStatus.done.rawValue
        } else {
            task.status = TaskStatus.open.rawValue
        }
        task.sprint = nil
    }
    
    private func isTaskDone(_ task: Task) -> Bool {
        return task.status == TaskStatus.done.rawValue
    }

    private func updateSprint(_ sprint: Sprint, with tasks: [Task], with newStartDate: Date, with newEndDate: Date) {
        sprint.startDate = newStartDate
        sprint.endDate = newEndDate
        sprint.status = SprintStatus.planned.rawValue
        sprint.tasks = tasks
    }
    

    private func assignTasks(_ tasks: [Task], to sprint: Sprint) {
        for task in tasks {
            task.status = TaskStatus.planned.rawValue
            task.sprint = sprint
        }
    }

    public func deleteSprint(_ sprint: Sprint) throws {
        sprint.tasks.forEach { $0.status = TaskStatus.open.rawValue }
        if let index = storedSprints.firstIndex(where: { $0.id == sprint.id }) {
            storedSprints.remove(at: index)
        }
        modelContext.delete(sprint)
        try modelContext.save()
    }
    
    
    
    public func getCurrentSprint() -> Sprint? {
        let today = Calendar.current.startOfDay(for: Date())
        return storedSprints.first(where: {
            let start = Calendar.current.startOfDay(for: $0.startDate)
            let end = Calendar.current.startOfDay(for: $0.endDate)
            return start <= today && end >= today
        })
    }
}
