import Foundation

struct Ingredient: Identifiable, Codable, Hashable {
    var id = UUID()
    var name: String
    var amount: String
}

struct Recipe: Identifiable, Codable, Hashable {
    var id = UUID()
    var title: String
    var imageURL: URL?
    var ingredients: [Ingredient] = []
    var steps: [String] = []
}
