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
                    NavigationStackExampleView()
                }

                NavigationLink("NavigationLink") {
                    NavigationLinkExampleView()
                }

                NavigationLink("TabView") {
                    TabViewExampleView()
                }

                NavigationLink("List") {
                    ListExampleView()
                }

                NavigationLink("Sheet Navigation") {
                    SheetNavigationExampleView()
                }
            }
            .navigationTitle("Navigation")
        }
    }
}

private struct NavigationStackExampleView: View {
    var body: some View {
        NavigationStack {
            List {
                NavigationLink("Go to detail") {
                    DetailMessageView(
                        title: "NavigationStack Detail",
                        message: "A NavigationStack manages a path of destinations."
                    )
                }
            }
            .navigationTitle("Inner Stack")
        }
        .navigationTitle("NavigationStack")
        .navigationBarTitleDisplayMode(.inline)
    }
}

private struct NavigationLinkExampleView: View {
    var body: some View {
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
        .navigationTitle("NavigationLink")
        .navigationBarTitleDisplayMode(.inline)
    }
}

private struct TabViewExampleView: View {
    var body: some View {
        TabView {
            ExampleCard(text: "Home tab")
                .tabItem {
                    Label("Home", systemImage: "house")
                }

            ExampleCard(text: "Search tab")
                .tabItem {
                    Label("Search", systemImage: "magnifyingglass")
                }
        }
        .navigationTitle("TabView")
        .navigationBarTitleDisplayMode(.inline)
    }
}

private struct ListExampleView: View {
    var body: some View {
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
        .navigationTitle("List")
        .navigationBarTitleDisplayMode(.inline)
    }
}

private struct SheetNavigationExampleView: View {
    @State private var showSheet = false

    var body: some View {
        ExampleScreen("Sheet Navigation") {
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
