import Foundation

enum Route: Hashable {
    case createSprint
    case sprintList
    case sprintEdit(Sprint)
    case sprintConfig
    case taskDetail(Task)
}
