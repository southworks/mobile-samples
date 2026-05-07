import SwiftUI

struct MVVMTaskListView: View {
    @StateObject private var viewModel = MVVMTaskListViewModel()
    @State private var isShowingCreateTaskAlert = false
    @State private var newTaskTitle = ""

    var body: some View {
        List {
            ForEach(viewModel.tasks) { task in
                TaskRowView(task: task)
            }
            .onDelete(perform: viewModel.deleteTask)
        }
        .navigationTitle("MVVM")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    newTaskTitle = ""
                    isShowingCreateTaskAlert = true
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .alert("Create Task", isPresented: $isShowingCreateTaskAlert) {
            TextField("Task title", text: $newTaskTitle)

            Button("Cancel", role: .cancel) {}

            Button("Create") {
                viewModel.createTask(title: newTaskTitle)
            }
        } message: {
            Text("Add a new task to the MVVM list.")
        }
    }
}

#Preview {
    NavigationStack {
        MVVMTaskListView()
    }
}
