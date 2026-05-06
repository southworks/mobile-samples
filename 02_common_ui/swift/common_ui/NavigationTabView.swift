//
//  NavigationTabView.swift
//  common_uiX
//

import SwiftUI

struct NavigationExamplesMenuView: View {
    @State private var showSheet = false
    var body: some View {
        NavigationStack {
            List {
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
                
                Button("Open sheet") {
                    showSheet = true
                }
            }
            .navigationTitle("Navigation")
            .sheet(isPresented: $showSheet) {
                NavigationStack {
                    List {
                        Section("Elements") {
                            ForEach(0..<10) { i in
                                NavigationLink("Element \(i)") {
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
