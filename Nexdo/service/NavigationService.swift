import SwiftUI

class NavigationService: ObservableObject {
    @Published var path: [Route] = []

    func goToCreateSprint() {
        path.append(.createSprint)
    }
    
    func goToSprintList() {
        path.append(.sprintList)
    }
    
    func goToEditSprint(_ sprint: Sprint) {
        path.append(.sprintEdit(sprint))
    }
 
    func goToSprintConfig() {
         path.append(.sprintConfig)
    }
    
    func goToTaskDetail(_ task: Task) {
        path.append(.taskDetail(task))
    }
        
}
