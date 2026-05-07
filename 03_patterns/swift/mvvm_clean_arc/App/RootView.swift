import SwiftUI

struct RootView: View {
    var body: some View {
        NavigationStack {
            List {
                NavigationLink("MVVM Task Manager") {
                    MVVMTaskListView()
                }

                NavigationLink("Clean Arc Task Manager") {
                    CleanTaskListScreen()
                }
            }
            .navigationTitle("Task Manager")
        }
    }
}

#Preview {
    RootView()
}
