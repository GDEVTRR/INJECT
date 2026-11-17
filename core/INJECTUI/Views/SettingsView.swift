import SwiftUI

struct SettingsView: View {

    @AppStorage("injectAppearance")
    private var appearance = "dark"

    var body: some View {
        NavigationStack {
            Form {
                Section("Appearance") {
                    Picker("Theme", selection: $appearance) {
                        Text("Dark").tag("dark")
                        Text("Light").tag("light")
                        Text("System").tag("system")
                    }
                }

                Section("About") {
                    LabeledContent("Application", value: "INJECT")
                    LabeledContent("Version", value: "0.1.0")
                    LabeledContent("Bundle ID", value: "com.gdev.inject")
                }

                Section {
                    Text("INJECT is an iOS customization research project.")
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle("Settings")
        }
    }
}