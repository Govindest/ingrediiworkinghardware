// Models/Recipe.swift

import Foundation

struct Recipe: Identifiable, Codable {
    // we generate an ID after decoding
    var id = UUID()

    let title: String
    let ingredients: [String]
    let calories: Int?

    private enum CodingKeys: String, CodingKey {
        case title, ingredients, calories
    }
}
