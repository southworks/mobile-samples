//
//  InputsTabView.swift
//  common_ui
//

import SwiftUI

struct InputsMenuView: View {
    var body: some View {
        NavigationStack {
            InputsExampleView()
        }
    }
}

private struct InputsExampleView: View {
    @State private var showAlert = false
    @State private var notificationsEnabled = false
    @State private var showDialog = false
    @State private var selectedColor = "Blue"
    @State private var selectedDate = Date()
    @State private var showSheet = false
    @State private var showPopover = false
    @State private var amount = 40.0
    @State private var username = ""
    @State private var password = ""
    @State private var showFullScreenCover = false
    @State private var notes = "Write a few lines here..."

    private let colors = ["Blue", "Green", "Orange"]

    var body: some View {
        ExampleScreen("Inputs") {
            sectionTitle("Button + Alert")
            Text("This button triggers an alert.")
                .foregroundStyle(.secondary)

            Button("Show Alert") {
                showAlert = true
            }
            .buttonStyle(.borderedProminent)

            Divider()

            sectionTitle("Toggle + ConfirmationDialog")
            Toggle("Activate notifications", isOn: $notificationsEnabled)
                .onChange(of: notificationsEnabled) { _, newValue in
                    if newValue {
                        showDialog = true
                    }
                }

            Text(notificationsEnabled ? "Notifications enabled" : "Notifications disabled")
                .foregroundStyle(.secondary)

            Divider()

            sectionTitle("Picker + Sheet")
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

            Divider()

            sectionTitle("DatePicker + Popover")
            DatePicker("Choose a date", selection: $selectedDate, displayedComponents: .date)

            Button("Show Selected Date") {
                showPopover = true
            }
            .buttonStyle(.bordered)

            Divider()

            sectionTitle("Slider")
            Text("Brightness: \(Int(amount))%")
            Slider(value: $amount, in: 0...100, step: 1)

            RoundedRectangle(cornerRadius: 16)
                .fill(.yellow.opacity(max(amount / 100, 0.15)))
                .frame(height: 120)
                .overlay {
                    Text("Live preview")
                        .fontWeight(.semibold)
                }

            Divider()

            sectionTitle("TextField")
            TextField("Enter your username", text: $username)
                .textFieldStyle(.roundedBorder)

            Text(username.isEmpty ? "No text entered" : "Current text: \(username)")
                .foregroundStyle(.secondary)

            Divider()

            sectionTitle("SecureField + FullScreenCover")
            SecureField("Enter a password", text: $password)
                .textFieldStyle(.roundedBorder)

            Button("Open Full Screen") {
                showFullScreenCover = true
            }
            .buttonStyle(.borderedProminent)

            Divider()

            sectionTitle("TextEditor")
            TextEditor(text: $notes)
                .frame(height: 180)
                .padding(8)
                .overlay {
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color(.systemGray4), lineWidth: 1)
                }
        }
        .alert("Button tapped", isPresented: $showAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Alerts are useful for important feedback.")
        }
        .confirmationDialog("Choose a notification frequency", isPresented: $showDialog) {
            Button("Daily") { }
            Button("Weekly") { }
            Button("Cancel", role: .cancel) {
                notificationsEnabled = false
            }
        } message: {
            Text("Confirmation dialogs present a few related actions.")
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
        .popover(isPresented: $showPopover) {
            VStack(spacing: 12) {
                Text("Selected Date")
                    .font(.headline)
                Text(selectedDate.formatted(date: .long, time: .omitted))
            }
            .padding()
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

    private func sectionTitle(_ title: String) -> some View {
        Text(title)
            .font(.headline)
    }
}
