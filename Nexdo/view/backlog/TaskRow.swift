import SwiftUI
import SwiftData

struct TaskRow: View {
    let task: Task
    let modelContext: ModelContext
    
    var body: some View {
        HStack(spacing: 15) {
            Button {
                toggleStatus(for: task)
            } label: {
                Circle()
                    .strokeBorder(Color.blue, lineWidth: 2)
                    .background(
                        Circle()
                            .fill(task.status == TaskStatus.done.rawValue ? Color.blue : Color.clear)
                    )
                    .frame(width: 24, height: 24)
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
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 6, x: 0, y: 3)
    }
    
    private func toggleStatus(for task: Task) {
        let open = TaskStatus.open.rawValue
        let done = TaskStatus.done.rawValue
        task.status = task.status == open ? done : open
        try? modelContext.save()
    }
}
