//
//  InputsTabView.swift
//  common_ui
//

import SwiftUI

struct InputsMenuView: View {
    var body: some View {
        NavigationStack {
            List {
                NavigationLink("Button") {
                    ButtonExampleView()
                }

                NavigationLink("Toggle") {
                    ToggleExampleView()
                }

                NavigationLink("Picker") {
                    PickerExampleView()
                }

                NavigationLink("DatePicker") {
                    DatePickerExampleView()
                }

                NavigationLink("Slider") {
                    SliderExampleView()
                }

                NavigationLink("TextField") {
                    TextFieldExampleView()
                }

                NavigationLink("SecureField") {
                    SecureFieldExampleView()
                }

                NavigationLink("TextEditor") {
                    TextEditorExampleView()
                }
            }
            .navigationTitle("Inputs")
        }
    }
}

private struct ButtonExampleView: View {
    @State private var showAlert = false

    var body: some View {
        ExampleScreen("Button + Alert") {
            Text("This button triggers an alert.")
                .foregroundStyle(.secondary)

            Button("Show Alert") {
                showAlert = true
            }
            .buttonStyle(.borderedProminent)
        }
        .alert("Button tapped", isPresented: $showAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Alerts are useful for important feedback.")
        }
    }
}

private struct ToggleExampleView: View {
    @State private var isEnabled = false
    @State private var showDialog = false

    var body: some View {
        ExampleScreen("Toggle + ConfirmationDialog") {
            Toggle("Activate notifications", isOn: $isEnabled)
                .onChange(of: isEnabled) { _, newValue in
                    if newValue {
                        showDialog = true
                    }
                }

            Text(isEnabled ? "Notifications enabled" : "Notifications disabled")
                .foregroundStyle(.secondary)
        }
        .confirmationDialog("Choose a notification frequency", isPresented: $showDialog) {
            Button("Daily") { }
            Button("Weekly") { }
            Button("Cancel", role: .cancel) {
                isEnabled = false
            }
        } message: {
            Text("Confirmation dialogs present a few related actions.")
        }
    }
}

private struct PickerExampleView: View {
    @State private var selectedColor = "Blue"
    @State private var showSheet = false
    private let colors = ["Blue", "Green", "Orange"]

    var body: some View {
        ExampleScreen("Picker + Sheet") {
            Picker("Theme color", selection: $selectedColor) {
                ForEach(colors, id: \.self) { color in
                    Text(color).tag(color)
                }
            }
            .pickerStyle(.segmented)

            Button("Preview Selection") {
                showSheet = true
            }
            .buttonStyle(.bordered)
        }
        .sheet(isPresented: $showSheet) {
            NavigationStack {
                VStack(spacing: 16) {
                    Text("Selected color")
                        .font(.headline)
                    Text(selectedColor)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                }
                .padding()
                .navigationTitle("Sheet")
            }
            .presentationDetents([.medium])
        }
    }
}

private struct DatePickerExampleView: View {
    @State private var selectedDate = Date()
    @State private var showPopover = false

    var body: some View {
        ExampleScreen("DatePicker + Popover") {
            DatePicker("Choose a date", selection: $selectedDate, displayedComponents: .date)

            Button("Show Selected Date") {
                showPopover = true
            }
            .buttonStyle(.bordered)
            .popover(isPresented: $showPopover) {
                VStack(spacing: 12) {
                    Text("Selected Date")
                        .font(.headline)
                    Text(selectedDate.formatted(date: .long, time: .omitted))
                }
                .padding()
            }
        }
    }
}

private struct SliderExampleView: View {
    @State private var amount = 40.0

    var body: some View {
        ExampleScreen("Slider") {
            Text("Brightness: \(Int(amount))%")
            Slider(value: $amount, in: 0...100, step: 1)

            RoundedRectangle(cornerRadius: 16)
                .fill(.yellow.opacity(max(amount / 100, 0.15)))
                .frame(height: 120)
                .overlay {
                    Text("Live preview")
                        .fontWeight(.semibold)
                }
        }
    }
}

private struct TextFieldExampleView: View {
    @State private var username = ""
    @State private var showSheet = false

    var body: some View {
        ExampleScreen("TextField + Sheet") {
            TextField("Enter your username", text: $username)
                .textFieldStyle(.roundedBorder)

            Button("Review Text") {
                showSheet = true
            }
            .buttonStyle(.bordered)
        }
        .sheet(isPresented: $showSheet) {
            VStack(spacing: 16) {
                Text("Current value")
                    .font(.headline)
                Text(username.isEmpty ? "No text entered" : username)
                    .font(.title2)
            }
            .padding()
            .presentationDetents([.medium])
        }
    }
}

private struct SecureFieldExampleView: View {
    @State private var password = ""
    @State private var showFullScreenCover = false

    var body: some View {
        ExampleScreen("SecureField + FullScreenCover") {
            SecureField("Enter a password", text: $password)
                .textFieldStyle(.roundedBorder)

            Button("Open Full Screen") {
                showFullScreenCover = true
            }
            .buttonStyle(.borderedProminent)
        }
        .fullScreenCover(isPresented: $showFullScreenCover) {
            NavigationStack {
                VStack(spacing: 16) {
                    Image(systemName: "lock.shield")
                        .font(.system(size: 60))
                        .foregroundStyle(.blue)

                    Text("Secure content preview")
                        .font(.title2)

                    Text("Typed characters: \(password.count)")
                        .foregroundStyle(.secondary)

                    Button("Close") {
                        showFullScreenCover = false
                    }
                    .buttonStyle(.borderedProminent)
                }
                .padding()
                .navigationTitle("Full Screen")
            }
        }
    }
}

private struct TextEditorExampleView: View {
    @State private var notes = "Write a few lines here..."
    @State private var showDialog = false

    var body: some View {
        ExampleScreen("TextEditor + ConfirmationDialog") {
            TextEditor(text: $notes)
                .frame(height: 180)
                .padding(8)
                .overlay {
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color(.systemGray4), lineWidth: 1)
                }

            Button("Editor Actions") {
                showDialog = true
            }
            .buttonStyle(.bordered)
        }
        .confirmationDialog("Choose an action", isPresented: $showDialog) {
            Button("Clear text") {
                notes = ""
            }
            Button("Insert sample") {
                notes = "SwiftUI TextEditor is useful for multiline input."
            }
            Button("Cancel", role: .cancel) { }
        }
    }
}
