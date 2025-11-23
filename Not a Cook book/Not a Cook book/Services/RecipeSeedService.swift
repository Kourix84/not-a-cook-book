import Foundation

final class RecipeSeedService {
    static let shared = RecipeSeedService()
    private let apiKey = "22962cfe689b4bcbbc6dfedfad6eec0c"  // <-- Paste your API key here

    private var cacheURL: URL {
        let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        return dir.appendingPathComponent("seed_recipes.json")
    }

    // MARK: - Fetch recipes if not cached
    func seedIfNeeded() async {
        if FileManager.default.fileExists(atPath: cacheURL.path) { return }
        do {
            let recipes = try await fetchRandomRecipes(total: 100)
            let data = try JSONEncoder().encode(recipes)
            try data.write(to: cacheURL, options: .atomic)
            print("✅ Seeded \(recipes.count) recipes → \(cacheURL.lastPathComponent)")
        } catch {
            print("❌ Seeding failed:", error)
        }
    }

    func loadSeed() -> [Recipe] {
        guard let data = try? Data(contentsOf: cacheURL) else { return [] }
        return (try? JSONDecoder().decode([Recipe].self, from: data)) ?? []
    }

    // MARK: - Spoonacular API
    private func fetchRandomRecipes(total: Int) async throws -> [Recipe] {
        var result: [Recipe] = []
        let chunk = 10
        let rounds = max(1, total / chunk)

        for _ in 0..<rounds {
            var comps = URLComponents(string: "https://api.spoonacular.com/recipes/random")!
            comps.queryItems = [
                .init(name: "number", value: "\(chunk)"),
                .init(name: "apiKey", value: apiKey)
            ]
            let url = comps.url!
            let (data, resp) = try await URLSession.shared.data(from: url)
            guard (resp as? HTTPURLResponse)?.statusCode == 200 else {
                let body = String(data: data, encoding: .utf8) ?? ""
                throw URLError(.badServerResponse, userInfo: ["Body": body])
            }

            let decoded = try JSONDecoder().decode(RandomResponse.self, from: data)
            result.append(contentsOf: decoded.recipes.map { r in
                Recipe(
                    title: r.title,
                    imageURL: URL(string: r.image ?? ""),
                    ingredients: r.extendedIngredients.map {
                        Ingredient(
                            name: $0.originalName ?? $0.name ?? "Ingredient",
                            amount: "\($0.measures?.metric?.amount ?? 0) \($0.measures?.metric?.unitShort ?? "")"
                        )
                    },
                    steps: r.analyzedInstructions.first?.steps.map { $0.step } ?? []
                )
            })

            try await Task.sleep(nanoseconds: 300_000_000) // Pause 0.3s between requests (avoid rate limits)
        }

        return result
    }

    // MARK: - API Response
    private struct RandomResponse: Codable {
        let recipes: [R]
        struct R: Codable {
            let title: String
            let image: String?
            let extendedIngredients: [Ing]
            let analyzedInstructions: [Instr]
        }
        struct Ing: Codable {
            let name: String?
            let originalName: String?
            let measures: Measures?
        }
        struct Measures: Codable {
            let metric: M?
            struct M: Codable {
                let amount: Double?
                let unitShort: String?
            }
        }
        struct Instr: Codable {
            let steps: [Step]
            struct Step: Codable { let step: String }
        }
    }
}
