//
//  NavigationTabView.swift
//  common_ui
//

import SwiftUI

struct NavigationExamplesMenuView: View {
    var body: some View {
        NavigationStack {
            List {
                NavigationLink("NavigationStack") {
                    NavigationStackDestinationView()
                }

                NavigationLink("NavigationLink") {
                    NavigationLinkDestinationView()
                }

                NavigationLink("Sheet Navigation") {
                    SheetNavigationDestinationView()
                }
            }
            .navigationTitle("Navigation")
        }
    }
}

private struct NavigationStackDestinationView: View {
    var body: some View {
        NavigationStack {
            List {
                Section("Planets") {
                    NavigationLink("Mercury") {
                        DetailMessageView(
                            title: "Mercury",
                            message: "This detail was pushed from a list inside a dedicated NavigationStack example."
                        )
                    }

                    NavigationLink("Venus") {
                        DetailMessageView(
                            title: "Venus",
                            message: "NavigationStack manages the path for this destination."
                        )
                    }
                }

                Section("Stars") {
                    NavigationLink("Sun") {
                        DetailMessageView(
                            title: "Sun",
                            message: "This is another destination in the same stack."
                        )
                    }
                }
            }
            .navigationTitle("NavigationStack")
        }
    }
}

private struct NavigationLinkDestinationView: View {
    var body: some View {
        List {
            Section("Cities") {
                NavigationLink("Buenos Aires") {
                    DetailMessageView(
                        title: "Buenos Aires",
                        message: "This destination comes from a NavigationLink inside a list."
                    )
                }

                NavigationLink("Tokyo") {
                    DetailMessageView(
                        title: "Tokyo",
                        message: "Each NavigationLink can open a different detail."
                    )
                }

                NavigationLink("Madrid") {
                    DetailMessageView(
                        title: "Madrid",
                        message: "This is a third destination to compare link behavior."
                    )
                }
            }
        }
        .navigationTitle("NavigationLink")
        .navigationBarTitleDisplayMode(.inline)
    }
}

private struct SheetNavigationDestinationView: View {
    @State private var showSheet = false

    var body: some View {
        ExampleScreen("Sheet Navigation") {
            Text("This example opens a sheet that contains its own navigation flow based on a list.")
                .foregroundStyle(.secondary)

            Button("Open Sheet") {
                showSheet = true
            }
            .buttonStyle(.borderedProminent)
        }
        .sheet(isPresented: $showSheet) {
            NavigationStack {
                List {
                    Section("Courses") {
                        NavigationLink("SwiftUI Basics") {
                            DetailMessageView(
                                title: "SwiftUI Basics",
                                message: "This detail is being shown inside a sheet-hosted NavigationStack."
                            )
                        }

                        NavigationLink("State Management") {
                            DetailMessageView(
                                title: "State Management",
                                message: "A second destination inside the same sheet example."
                            )
                        }
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
