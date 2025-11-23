import SwiftUI

@main
struct NotACookbookApp: App {
    var body: some Scene {
        WindowGroup {
            TabView {
                HomeView()
                    .tabItem { Label("Home", systemImage: "house") }

                RecipesView()
                    .tabItem { Label("Recipes", systemImage: "book") }

                AIView()
                    .tabItem { Label("AI", systemImage: "sparkles") }

                SettingsView()
                    .tabItem { Label("Settings", systemImage: "gearshape") }
            }
            .preferredColorScheme(.dark)
        }
    }
}
