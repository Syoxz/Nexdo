import Foundation
import SwiftData

@Model
class Sprint {
    @Attribute(.unique) var id: UUID
    var startDate: Date
    var endDate: Date
    var status: String

    @Relationship(deleteRule: .nullify, inverse: \Task.sprint)
    var tasks: [Task]

    init(id: UUID = UUID(), startDate: Date, endDate: Date, status: SprintStatus, tasks: [Task] = []) {
        self.id = id
        self.startDate = startDate
        self.endDate = endDate
        self.status = status.rawValue
        self.tasks = tasks
    }
}

extension Sprint {
    static func currentSprint() -> Predicate<Sprint> {
        let currentDate = Date.now
        return #Predicate<Sprint> { sprint in
            sprint.startDate <= currentDate && sprint.endDate >= currentDate
        }
    }
}
