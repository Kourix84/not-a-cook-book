import SwiftUI

struct SettingsView: View {
    var body: some View {
        NavigationStack {
            Form {
                Section("App") {
                    Text("Not A Cookbook v2.1.1")
                    Link("Privacy Policy", destination: URL(string: "https://example.com")!)
                }
            }
            .navigationTitle("Settings")
        }
    }
}
