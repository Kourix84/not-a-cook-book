import SwiftUI

struct RecipesView: View {
    @State private var all: [Recipe] = []
    @State private var query = ""
    @State private var loading = true

    var filtered: [Recipe] {
        query.isEmpty ? all : all.filter { $0.title.lowercased().contains(query.lowercased()) }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 12) {
                HStack {
                    Image(systemName: "magnifyingglass")
                    TextField("Search recipes…", text: $query)
                }
                .padding(12)
                .background(Color(.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 14))
                .padding(.horizontal)

                if loading {
                    ProgressView("Loading recipes…")
                        .padding(.top, 20)
                } else {
                    List(filtered) { r in
                        NavigationLink { RecipeDetailView(recipe: r) } label: {
                            RecipeRow(recipe: r)
                        }
                        .listRowSeparator(.hidden)
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("Recipe’s")
            .task {
                await RecipeSeedService.shared.seedIfNeeded()
                all = RecipeSeedService.shared.loadSeed()
                loading = false
            }
        }
    }
}

private struct RecipeRow: View {
    let recipe: Recipe
    var body: some View {
        HStack(spacing: 12) {
            AsyncImage(url: recipe.imageURL) { phase in
                switch phase {
                case .success(let image): image.resizable().scaledToFill()
                case .failure(_): Image(systemName: "fork.knife.circle").resizable().scaledToFit().padding(14)
                case .empty: ProgressView()
                @unknown default: Color.clear
                }
            }
            .frame(width: 72, height: 72)
            .background(Color(.tertiarySystemFill))
            .clipShape(RoundedRectangle(cornerRadius: 10))

            VStack(alignment: .leading, spacing: 6) {
                Text(recipe.title).font(.headline)
                HStack(spacing: 16) {
                    Label("20 min", systemImage: "clock")
                    Label("Easy", systemImage: "fork.knife")
                }
                .font(.caption).foregroundStyle(.secondary)
            }
            Spacer()
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 22))
        .overlay(RoundedRectangle(cornerRadius: 22).stroke(Color.white.opacity(0.1), lineWidth: 1))
    }
}
