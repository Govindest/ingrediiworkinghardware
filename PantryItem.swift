// Models/PantryItem.swift

import Foundation

struct PantryItem: Identifiable, Equatable {
  let id: UUID
  var barcode: String
  var name: String
  var imageName: String
  var quantity: Int
  var expiryDate: Date
  var isStaple: Bool

  init(
    id: UUID = .init(),
    barcode: String,
    name: String,
    imageName: String,
    quantity: Int,
    expiryDate: Date,
    isStaple: Bool
  ) {
    self.id = id
    self.barcode = barcode
    self.name = name
    self.imageName = imageName
    self.quantity = quantity
    self.expiryDate = expiryDate
    self.isStaple = isStaple
  }
}
