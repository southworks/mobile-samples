//
//  NavigationTabView.swift
//  common_ui
//

import SwiftUI

struct NavigationExamplesMenuView: View {
    var body: some View {
        NavigationStack {
            NavigationExamplesView()
        }
    }
}

private struct NavigationExamplesView: View {
    @State private var showSheet = false

    var body: some View {
        ExampleScreen("Navigation") {
            Text("NavigationStack")
                .font(.headline)

            Text("A NavigationStack manages a path of destinations.")
                .foregroundStyle(.secondary)

            List {
                NavigationLink("Go to stack detail") {
                    DetailMessageView(
                        title: "NavigationStack Detail",
                        message: "This detail is pushed from a list inside the navigation example."
                    )
                }
            }
            .frame(height: 90)
            .clipShape(RoundedRectangle(cornerRadius: 12))

            Divider()

            Text("NavigationLink")
                .font(.headline)

            Text("Each NavigationLink can open a different destination.")
                .foregroundStyle(.secondary)

            List {
                NavigationLink("Open first detail") {
                    DetailMessageView(
                        title: "First Destination",
                        message: "NavigationLink pushes a new view onto the current stack."
                    )
                }

                NavigationLink("Open second detail") {
                    DetailMessageView(
                        title: "Second Destination",
                        message: "Each link can navigate to a different view."
                    )
                }
            }
            .frame(height: 140)
            .clipShape(RoundedRectangle(cornerRadius: 12))

            Divider()

            Text("List")
                .font(.headline)

            List {
                Section("Fruits") {
                    Text("Apple")
                    Text("Banana")
                    Text("Orange")
                }

                Section("Vegetables") {
                    Text("Carrot")
                    Text("Tomato")
                }
            }
            .frame(height: 180)
            .clipShape(RoundedRectangle(cornerRadius: 12))

            Divider()

            Text("Sheet Navigation")
                .font(.headline)

            Text("A sheet can present its own NavigationStack.")
                .foregroundStyle(.secondary)

            Button("Open Sheet") {
                showSheet = true
            }
            .buttonStyle(.borderedProminent)
        }
        .sheet(isPresented: $showSheet) {
            NavigationStack {
                List {
                    NavigationLink("Open sheet detail") {
                        DetailMessageView(
                            title: "Sheet Detail",
                            message: "This navigation happens inside the presented sheet."
                        )
                    }

                    NavigationLink("Open another sheet detail") {
                        DetailMessageView(
                            title: "Sheet Second Detail",
                            message: "This is a second list-based navigation example inside the sheet."
                        )
                    }
                }
                .navigationTitle("Sheet")
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Done") {
                            showSheet = false
                        }
                    }
                }
            }
        }
    }
}
