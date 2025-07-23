// Models/NutritionInfo.swift

import Foundation

/// A simplified nutrition info record for a single food item.
struct NutritionInfo: Codable {
    let fdcId: Int
    let description: String
    /// Kilocalories per 100 g
    let caloriesPer100g: Double
}
