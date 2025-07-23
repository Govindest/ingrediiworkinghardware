import Foundation

@MainActor
class PantryStore: ObservableObject {
  @Published var pantryItems  : [PantryItem] = []
  @Published var fridgeItems  : [PantryItem] = []
  @Published var groceryItems : [PantryItem] = []
  @Published var currentSection: StorageSection = .pantry

  func updateCurrentSection(_ sec: StorageSection) {
    currentSection = sec
  }

  func increment(barcode: String, info: NutritionInfo?, in section: StorageSection) {
    let newItem = PantryItem(
      barcode: barcode,
      name:    info?.description ?? barcode,
      quantity: 1
    )
    add(newItem, to: section)
  }

  func decrement(barcode: String, in section: StorageSection) {
    switch section {
    case .pantry:
      if let idx = pantryItems.firstIndex(where: { $0.barcode == barcode }) {
        if pantryItems[idx].quantity > 1 {
          pantryItems[idx].quantity -= 1
        } else {
          pantryItems.remove(at: idx)
        }
      }
    case .fridge:
      if let idx = fridgeItems.firstIndex(where: { $0.barcode == barcode }) {
        if fridgeItems[idx].quantity > 1 {
          fridgeItems[idx].quantity -= 1
        } else {
          fridgeItems.remove(at: idx)
        }
      }
    case .grocery:
      if let idx = groceryItems.firstIndex(where: { $0.barcode == barcode }) {
        if groceryItems[idx].quantity > 1 {
          groceryItems[idx].quantity -= 1
        } else {
          groceryItems.remove(at: idx)
        }
      }
    }
  }

  func add(_ item: PantryItem, to section: StorageSection = .pantry) {
    switch section {
    case .pantry:  pantryItems.append(item)
    case .fridge:  fridgeItems.append(item)
    case .grocery: groceryItems.append(item)
    }
  }

  /// **NEW** helper to get a Binding<…> for edit forms
  func binding(for item: PantryItem, in section: StorageSection) -> Binding<PantryItem> {
    switch section {
    case .pantry:
      let idx = pantryItems.firstIndex { $0.id == item.id }!
      return $pantryItems[idx]
    case .fridge:
      let idx = fridgeItems.firstIndex { $0.id == item.id }!
      return $fridgeItems[idx]
    case .grocery:
      let idx = groceryItems.firstIndex { $0.id == item.id }!
      return $groceryItems[idx]
    }
  }
}
