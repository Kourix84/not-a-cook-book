import Foundation

final class SpoonacularService {
    static let shared = SpoonacularService()
    private let apiKey = "22962cfe689b4bcbbc6dfedfad6eec0c" // <-- paste your key

    struct APIError: Error, LocalizedError {
        let message: String
        var errorDescription: String? { message }
    }

    // A lightweight suggestion for the UI
    struct SuggestedRecipe: Identifiable, Hashable {
        let id: Int
        let title: String
    }

    // --- Public: get top suggestions from an image
    func suggestRecipes(imageURL: URL, limit: Int = 5) async throws -> [SuggestedRecipe] {
        let analysis = try await analyzeImage(imageURL: imageURL)
        let items = analysis.recipes.prefix(limit).map { SuggestedRecipe(id: $0.id, title: $0.title ?? "Recipe \($0.id)") }
        if items.isEmpty { throw APIError(message: "No related recipes found for this image.") }
        return Array(items)
    }

    // --- Public: fetch ingredients for a known recipe id
    func ingredients(for recipeID: Int) async throws -> [Ingredient] {
        let info = try await fetchRecipeInformation(id: recipeID)
        return info.extendedIngredients.map { ing in
            var amountText = ""
            if let m = ing.measures?.metric, let a = m.amount {
                let unit = m.unitShort ?? ""
                amountText = a.rounded(.down) == a ? "\(Int(a)) \(unit)" : String(format: "%.2f %@", a, unit)
                amountText = amountText.trimmingCharacters(in: .whitespaces)
            }
            return Ingredient(name: ing.originalName ?? ing.name ?? "Ingredient", amount: amountText)
        }
    }

    // MARK: - Step 1: /food/images/analyze
    private func analyzeImage(imageURL: URL) async throws -> ImageAnalysisResponse {
        var comps = URLComponents(string: "https://api.spoonacular.com/food/images/analyze")!
        comps.queryItems = [
            URLQueryItem(name: "imageUrl", value: imageURL.absoluteString),
            URLQueryItem(name: "apiKey", value: apiKey)
        ]
        let url = comps.url!
        print("🔵 Spoonacular analyze → \(url.absoluteString)")

        let (data, resp) = try await URLSession.shared.data(from: url)
        guard let http = resp as? HTTPURLResponse else { throw URLError(.badServerResponse) }

        if http.statusCode != 200 {
            let body = String(data: data, encoding: .utf8) ?? "<no body>"
            print("❌ Analyze \(http.statusCode): \(body)")
            throw mapHTTPError(http.statusCode, body: body)
        }

        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return try decoder.decode(ImageAnalysisResponse.self, from: data)
    }

    // MARK: - Step 2: /recipes/{id}/information
    private func fetchRecipeInformation(id: Int) async throws -> RecipeInformationResponse {
        var comps = URLComponents(string: "https://api.spoonacular.com/recipes/\(id)/information")!
        comps.queryItems = [
            URLQueryItem(name: "includeNutrition", value: "false"),
            URLQueryItem(name: "apiKey", value: apiKey)
        ]
        let url = comps.url!
        print("🔵 Spoonacular recipe info → \(url.absoluteString)")

        let (data, resp) = try await URLSession.shared.data(from: url)
        guard let http = resp as? HTTPURLResponse else { throw URLError(.badServerResponse) }

        if http.statusCode != 200 {
            let body = String(data: data, encoding: .utf8) ?? "<no body>"
            print("❌ Recipe info \(http.statusCode): \(body)")
            throw mapHTTPError(http.statusCode, body: body)
        }

        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return try decoder.decode(RecipeInformationResponse.self, from: data)
    }

    // MARK: - DTOs we actually use
    private struct ImageAnalysisResponse: Codable {
        struct RecipeLite: Codable { let id: Int; let title: String? }
        let status: String?
        let recipes: [RecipeLite]
    }

    private struct RecipeInformationResponse: Codable {
        let id: Int
        let title: String?
        let extendedIngredients: [ExtendedIngredient]

        struct ExtendedIngredient: Codable {
            let name: String?
            let originalName: String?
            let measures: Measures?
        }
        struct Measures: Codable {
            let metric: Metric?
            struct Metric: Codable {
                let amount: Double?
                let unitShort: String?
            }
        }
    }

    // MARK: - Helpers
    private func mapHTTPError(_ code: Int, body: String) -> APIError {
        switch code {
        case 401, 403: return APIError(message: "Invalid API key or access denied.")
        case 402, 429: return APIError(message: "Quota/rate limit exceeded.")
        case 400:      return APIError(message: "Bad request. Check the image URL.")
        default:       return APIError(message: "Server error \(code): \(body)")
        }
    }
}
