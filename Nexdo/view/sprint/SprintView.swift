import SwiftUI
import SwiftData

struct SprintView: View {
    @EnvironmentObject var navService: NavigationService

    @State private var showCreateSprint = false
    @State private var showConfig = false
    @State private var showSprints = false

    
    @Query(filter: Sprint.currentSprint())
    private var currentSprints: [Sprint]
    
    
    
    var body: some View {
        VStack() {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    VStack(alignment: .leading, spacing: 20) {
                        VStack(alignment: .leading, spacing: 12) {
                            currentSprintCard()
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color(.secondarySystemGroupedBackground))
                    .cornerRadius(20)
                    .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
                    
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Quick Actions")
                            .font(.headline)
                        
                        HStack(spacing: 16) {
                            SprintButton(title: "Create", icon: "plus.circle.fill", color: .blue) {
                                navService.goToCreateSprint()
                            }
                            
                            SprintButton(title: "Sprints", icon: "list.bullet.rectangle", color: .green) {
                                navService.goToSprintList()
                            }

                            SprintButton(title: "Config", icon: "gearshape.fill", color: .orange) {
                                navService.goToSprintConfig()
                            }
                        }
                    }
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color(.secondarySystemGroupedBackground))
                .cornerRadius(20)
                .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
                
                Spacer(minLength: 40)
            }
            .padding()

            .background(Color(.systemGroupedBackground).ignoresSafeArea())
            
        }
    }
    
    
    private func currentSprintCard() -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Current Sprint", systemImage: "flag.fill")
                .font(.headline)
                .foregroundColor(.blue)
            
            if let sprint = currentSprints.first {
                let daysRemaining = Calendar.current.dateComponents([.day], from: Date(), to: sprint.endDate).day ?? 0
                let totalTasksCount = sprint.tasks.count
                let completedTasksCount = sprint.tasks.filter { $0.status == TaskStatus.done.rawValue }.count
                
                VStack(alignment: .leading, spacing: 6) {
                    Text("Start: \(sprint.startDate.formatted(date: .abbreviated, time: .omitted))")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Text("Ends in \(daysRemaining) day\(daysRemaining == 1 ? "" : "s")")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    if totalTasksCount > 0 {
                        let progress = Double(completedTasksCount) / Double(totalTasksCount)
                        ProgressView(value: progress) {
                            Text("Progress")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        .progressViewStyle(LinearProgressViewStyle(tint: .blue))
                        
                        Text("\(completedTasksCount) of \(totalTasksCount) tasks completed")
                            .font(.footnote)
                            .foregroundColor(.secondary)
                    }
                }
            } else {
                Text("No Current Sprint")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
    }
}
