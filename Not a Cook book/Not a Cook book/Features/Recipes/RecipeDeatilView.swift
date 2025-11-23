import SwiftUI

struct RecipeDetailView: View {
    let recipe: Recipe

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                AsyncImage(url: recipe.imageURL) { phase in
                    switch phase {
                    case .success(let image): image.resizable().scaledToFill()
                    case .failure(_): Color.gray
                    case .empty: ProgressView()
                    @unknown default: Color.clear
                    }
                }
                .frame(height: 220)
                .clipShape(RoundedRectangle(cornerRadius: 22))

                // Ingredients
                VStack(alignment: .leading, spacing: 10) {
                    Text("Ingredients").font(.title3).bold()
                    if recipe.ingredients.isEmpty {
                        Text("No ingredients available.")
                            .foregroundColor(.secondary)
                    } else {
                        ForEach(recipe.ingredients) { ing in
                            Text("• \(ing.name) — \(ing.amount)")
                                .font(.subheadline)
                        }
                    }
                }

                // Steps
                VStack(alignment: .leading, spacing: 10) {
                    Text("Steps").font(.title3).bold()
                    if recipe.steps.isEmpty {
                        Text("No steps provided.")
                            .foregroundColor(.secondary)
                    } else {
                        ForEach(Array(recipe.steps.enumerated()), id: \.offset) { idx, step in
                            Text("\(idx + 1). \(step)")
                                .font(.subheadline)
                                .padding(.bottom, 4)
                        }
                    }
                }
            }
            .padding()
        }
        .navigationTitle(recipe.title)
    }
}
