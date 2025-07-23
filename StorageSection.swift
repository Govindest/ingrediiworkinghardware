// Models/StorageSection.swift

import Foundation

/// The three storage modes.
enum StorageSection: String, CaseIterable, Identifiable {
  case pantry, fridge, grocery
  var id: String { rawValue }
}
