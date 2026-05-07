import SwiftUI

struct CleanTaskListView: View {
    @StateObject private var viewModel: CleanTaskListViewModel
    @State private var isShowingCreateTaskAlert = false
    @State private var newTaskTitle = ""

    init(viewModel: CleanTaskListViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        List {
            ForEach(viewModel.tasks) { task in
                TaskRowView(task: task)
            }
            .onDelete(perform: viewModel.deleteTask)
        }
        .onAppear(perform: viewModel.loadTasks)
        .navigationTitle("Clean Arc")
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
            Text("Add a new task through the use cases.")
        }
    }
}

#Preview {
    NavigationStack {
        CleanTaskListView(viewModel: Dependencies.makeTaskListViewModel())
    }
}
