//
//  ContentView.swift
//  common_ui
//
//  Created by ec2-user on 5/6/26.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            WelcomeView()
                .tabItem {
                    Label("Intro", systemImage: "house")
                }

            FormControlsView()
                .tabItem {
                    Label("Form", systemImage: "slider.horizontal.3")
                }

            SelectionControlsView()
                .tabItem {
                    Label("Select", systemImage: "checklist")
                }

            FeedbackView()
                .tabItem {
                    Label("Feedback", systemImage: "bell")
                }
        }
    }
}

private struct WelcomeView: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("SwiftUI Basic Controls")
                        .font(.largeTitle)
                        .fontWeight(.bold)

                    Text("This sample project shows common SwiftUI controls in small, clear examples for learning purposes.")
                        .foregroundStyle(.secondary)

                    VStack(alignment: .leading, spacing: 12) {
                        FeatureRow(
                            icon: "textformat",
                            title: "Text and Labels",
                            description: "Display styled content and captions."
                        )
                        FeatureRow(
                            icon: "square.and.pencil",
                            title: "Form Inputs",
                            description: "Try text fields, toggles, sliders, and steppers."
                        )
                        FeatureRow(
                            icon: "list.bullet",
                            title: "Selection Views",
                            description: "Use pickers and segmented controls."
                        )
                        FeatureRow(
                            icon: "hand.thumbsup",
                            title: "User Feedback",
                            description: "Explore buttons, progress views, alerts, and dates."
                        )
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 16))

                    Text("Use the tabs below to explore each group.")
                        .font(.headline)
                }
                .padding()
            }
            .navigationTitle("Basics")
        }
    }
}

private struct FormControlsView: View {
    @State private var name = ""
    @State private var password = ""
    @State private var notificationsEnabled = true
    @State private var age = 18
    @State private var volume = 0.4

    var body: some View {
        NavigationStack {
            Form {
                Section("Text Input") {
                    TextField("Enter your name", text: $name)
                        .textInputAutocapitalization(.words)

                    SecureField("Enter a password", text: $password)

                    LabeledContent("Preview") {
                        Text(name.isEmpty ? "No name yet" : name)
                            .foregroundStyle(name.isEmpty ? .secondary : .primary)
                    }
                }

                Section("Interactive Controls") {
                    Toggle("Enable notifications", isOn: $notificationsEnabled)

                    Stepper("Age: \(age)", value: $age, in: 1...100)

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Volume: \(Int(volume * 100))%")
                        Slider(value: $volume, in: 0...1)
                    }
                }
            }
            .navigationTitle("Form Controls")
        }
    }
}

private struct SelectionControlsView: View {
    @State private var selectedTopic = "Text"
    @State private var selectedLevel = "Beginner"

    private let topics = ["Text", "Images", "Stacks", "Lists"]
    private let levels = ["Beginner", "Intermediate", "Advanced"]

    var body: some View {
        NavigationStack {
            Form {
                Section("Picker") {
                    Picker("Topic", selection: $selectedTopic) {
                        ForEach(topics, id: \.self) { topic in
                            Text(topic).tag(topic)
                        }
                    }
                }

                Section("Segmented Control") {
                    Picker("Level", selection: $selectedLevel) {
                        ForEach(levels, id: \.self) { level in
                            Text(level).tag(level)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                Section("Current Selection") {
                    Text("Topic: \(selectedTopic)")
                    Text("Level: \(selectedLevel)")
                }
            }
            .navigationTitle("Selection")
        }
    }
}

private struct FeedbackView: View {
    @State private var progress = 0.3
    @State private var showAlert = false
    @State private var selectedDate = Date()

    var body: some View {
        NavigationStack {
            Form {
                Section("Buttons") {
                    Button("Increase Progress") {
                        progress = min(progress + 0.1, 1.0)
                    }

                    Button("Show Alert") {
                        showAlert = true
                    }
                    .alert("SwiftUI Alert", isPresented: $showAlert) {
                        Button("OK", role: .cancel) { }
                    } message: {
                        Text("Alerts are useful for confirmations and important messages.")
                    }
                }

                Section("Progress") {
                    ProgressView(value: progress)

                    Text("\(Int(progress * 100))% complete")
                        .foregroundStyle(.secondary)
                }

                Section("Date Picker") {
                    DatePicker("Select a date", selection: $selectedDate, displayedComponents: .date)

                    Text(selectedDate.formatted(date: .abbreviated, time: .omitted))
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle("Feedback")
        }
    }
}

private struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .frame(width: 24)
                .foregroundStyle(.tint)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .fontWeight(.semibold)

                Text(description)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

#Preview {
    ContentView()
}
