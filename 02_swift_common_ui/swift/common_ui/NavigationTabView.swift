//
//  NavigationTabView.swift
//  common_uiX
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
                            message: "Mercury is the smallest planet in our solar system."
                        )
                    }

                    NavigationLink("Venus") {
                        DetailMessageView(
                            title: "Venus",
                            message: "Venus is the second planet from the Sun."
                        )
                    }
                }

                Section("Stars") {
                    NavigationLink("Sun") {
                        DetailMessageView(
                            title: "Sun",
                            message: "Sun is the star at the center of our solar system."
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
