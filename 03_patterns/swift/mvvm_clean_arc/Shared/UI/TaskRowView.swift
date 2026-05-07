import SwiftUI

struct TaskRowView: View {
    let task: TaskItem

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "checklist")
                .foregroundStyle(.blue)

            Text(task.title)
                .font(.body)

            Spacer()
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    TaskRowView(task: TaskItem(id: UUID(), title: "Buy groceries"))
        .padding()
}
