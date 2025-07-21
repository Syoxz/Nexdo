import SwiftData
import Foundation

@Model
class Task {
    @Attribute(.unique) var id: UUID
    var name: String
    var taskDescription: String
    var status: String
    var createdAt: Date
    var dueDate: Date?

    @Relationship var sprint: Sprint?

    init(id: UUID = UUID(), name: String, taskDescription: String, status: TaskStatus, createdAt: Date = Date(), dueDate: Date? = nil, sprint: Sprint? = nil) {
        self.id = id
        self.name = name
        self.taskDescription = taskDescription
        self.status = status.rawValue
        self.createdAt = createdAt
        self.dueDate = dueDate
        self.sprint = sprint
    }
}

extension Task {
    static func openTasks() -> Predicate<Task> {
        let openRaw = TaskStatus.open.rawValue
        return #Predicate<Task> { task in
            task.status == openRaw
        }
    }
}
