import SwiftUI
import SwiftData

struct TaskRow: View {
    let task: Task
    let modelContext: ModelContext
    var isDone: Bool {
        task.status == TaskStatus.done.rawValue
    }

    var body: some View {
        HStack(spacing: 13) {
            Button {
                toggleStatus(for: task)
            } label: {
                Image(systemName: isDone ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(isDone ? .blue : .gray)
                    .font(.system(size: 22, weight: .semibold))
            }
            .buttonStyle(.plain)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(task.name)
                    .font(.headline)
                    .foregroundColor(.primary)
                Text(task.taskDescription)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .strikethrough(isDone, color: .primary)
        .padding()
        .background(.thinMaterial)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.2), radius: 6, x: 0, y: 3)
    }
    
    private func toggleStatus(for task: Task) {
        do {
            let open = TaskStatus.open.rawValue
            let planned = TaskStatus.planned.rawValue
            let done = TaskStatus.done.rawValue

            let isTaskInSprint = task.sprint != nil
            if isTaskInSprint {
                task.status = task.status == planned ? done : planned
            } else {
                task.status = task.status == open ? done : open
            }
            try modelContext.save()
        } catch {
            print("Failed to toggle task status: \(error.localizedDescription)")
        }
    }
}
