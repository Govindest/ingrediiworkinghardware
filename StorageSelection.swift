import Foundation

enum StorageSection: String, CaseIterable, Identifiable {
  case pantry  = "Pantry"
  case fridge  = "Fridge"
  case grocery = "Grocery"

  var id: String { rawValue }
}
