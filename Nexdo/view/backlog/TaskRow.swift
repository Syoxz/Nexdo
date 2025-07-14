import SwiftUI
import SwiftData

struct TaskRow: View {
    let task: Task
    let modelContext: ModelContext
    @State private var isSelected: Bool = false

    var body: some View {
        HStack(spacing: 13) {
            Button {
                toggleStatus(for: task)
            } label: {
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(isSelected ? .blue : .gray)
                    .font(.system(size: 18, weight: .semibold))
                    .animation(.easeInOut(duration: 1), value: isSelected)
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
        isSelected.toggle()
        let open = TaskStatus.open.rawValue
        let done = TaskStatus.done.rawValue
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            withAnimation {
                task.status = task.status == open ? done : open
                try? modelContext.save()
            }
        }
    }

}
