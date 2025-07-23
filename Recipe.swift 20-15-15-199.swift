import Foundation

struct Recipe: Identifiable, Decodable {
  let id = UUID()
  let title: String
  let ingredients: [String]
  let calories: Int?
}
