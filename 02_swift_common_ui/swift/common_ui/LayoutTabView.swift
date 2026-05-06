//
//  LayoutTabView.swift
//  common_ui
//

import SwiftUI

struct LayoutMenuView: View {
    var body: some View {
        NavigationStack {
            List {
                NavigationLink("VStack") {
                    VStackExampleView()
                }

                NavigationLink("HStack") {
                    HStackExampleView()
                }

                NavigationLink("ZStack") {
                    ZStackExampleView()
                }

                NavigationLink("ScrollView") {
                    ScrollViewExampleView()
                }

                NavigationLink("LazyVStack") {
                    LazyVStackExampleView()
                }

                NavigationLink("Spacer") {
                    SpacerExampleView()
                }
            }
            .navigationTitle("Layout")
        }
    }
}

private struct VStackExampleView: View {
    var body: some View {
        ExampleScreen("VStack") {
            VStack(spacing: 12) {
                ExampleCard(text: "Top")
                ExampleCard(text: "Middle")
                ExampleCard(text: "Bottom")
            }
        }
    }
}

private struct HStackExampleView: View {
    var body: some View {
        ExampleScreen("HStack") {
            HStack(spacing: 12) {
                ExampleCard(text: "One")
                ExampleCard(text: "Two")
                ExampleCard(text: "Three")
            }
        }
    }
}

private struct ZStackExampleView: View {
    var body: some View {
        ExampleScreen("ZStack") {
            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .fill(.blue.opacity(0.2))
                    .frame(height: 180)

                Circle()
                    .fill(.blue.opacity(0.45))
                    .frame(width: 120, height: 120)

                Text("Layered content")
                    .font(.headline)
            }
        }
    }
}

private struct ScrollViewExampleView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                ForEach(1...12, id: \.self) { index in
                    ExampleCard(text: "Scrollable item \(index)")
                }
            }
            .padding()
        }
        .navigationTitle("ScrollView")
        .navigationBarTitleDisplayMode(.inline)
    }
}

private struct LazyVStackExampleView: View {
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(1...20, id: \.self) { index in
                    HStack {
                        Image(systemName: "square.stack.3d.up")
                        Text("Lazy row \(index)")
                        Spacer()
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }
            .padding()
        }
        .navigationTitle("LazyVStack")
        .navigationBarTitleDisplayMode(.inline)
    }
}

private struct SpacerExampleView: View {
    var body: some View {
        ExampleScreen("Spacer") {
            HStack {
                Text("Start")
                Spacer()
                Text("End")
            }
            .padding()
            .background(Color(.systemGray6))
            .clipShape(RoundedRectangle(cornerRadius: 12))

            VStack {
                Text("Top")
                Spacer()
                Text("Bottom")
            }
            .frame(height: 160)
            .padding()
            .background(Color(.systemGray6))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }
}
