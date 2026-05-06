//
//  NavigationTabView.swift
//  common_ui
//

import SwiftUI

struct NavigationExamplesMenuView: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
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
            .navigationTitle("Navigation")
            .sheet(isPresented: $showSheet) {
                NavigationStack {
                    List {
                        Section("Courses") {
                            for i in 0...10 {
                                NavigationLink("SwiftUI Basics") {
                                    DetailMessageView(
                                        title: "Navigation \(i)",
                                        message: "Detail message for navigation \(i)."
                                    )
                                }
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
}
