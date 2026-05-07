import SwiftUI

struct CleanTaskListScreen: View {
    @StateObject private var viewModel: CleanTaskListViewModel

    init(viewModel: CleanTaskListViewModel = Dependencies.makeTaskListViewModel()) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        CleanTaskListView(viewModel: viewModel)
    }
}

struct CleanTaskListView: View {
    @ObservedObject var viewModel: CleanTaskListViewModel
    @State private var isShowingCreateTaskAlert = false
    @State private var newTaskTitle = ""

    var body: some View {
        List {
            ForEach(viewModel.tasks) { task in
                TaskRowView(task: task)
            }
            .onDelete(perform: viewModel.deleteTask)
        }
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
        CleanTaskListScreen()
    }
}
