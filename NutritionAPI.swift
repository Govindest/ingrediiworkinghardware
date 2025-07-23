// Models/NutritionAPI.swift

import Foundation

/// Wraps USDA FoodData Central “foods/search” API to fetch calorie data.
final class NutritionAPI {
    static let shared = NutritionAPI()
    private init() {}

    private let apiKey = "HZU0VsoofGrfOMhb1eayvH9QBFYxWPi0vREAIBDN"
    private let session = URLSession.shared

    /// Searches FDC for the first matching food name and returns its NutritionInfo.
    func fetchCalories(for query: String, completion: @escaping (NutritionInfo?) -> Void) {
        guard
            let q = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
            let url = URL(string:
                "https://api.nal.usda.gov/fdc/v1/foods/search?" +
                "api_key=\(apiKey)&query=\(q)&pageSize=1")
        else {
            completion(nil)
            return
        }

        session.dataTask(with: url) { data, _, error in
            guard error == nil, let data = data else {
                DispatchQueue.main.async { completion(nil) }
                return
            }
            do {
                let root = try JSONDecoder().decode(FDCSearchResponse.self, from: data)
                guard let first = root.foods.first,
                      let energy = first.foodNutrients.first(where: { $0.nutrientNumber == "208" })
                else {
                    DispatchQueue.main.async { completion(nil) }
                    return
                }
                let info = NutritionInfo(
                    fdcId: first.fdcId,
                    description: first.description,
                    caloriesPer100g: energy.value
                )
                DispatchQueue.main.async { completion(info) }
            } catch {
                DispatchQueue.main.async { completion(nil) }
            }
        }.resume()
    }

    /// Looks up a UPC/barcode (branded foods) and returns its NutritionInfo.
    func fetchNutritionByBarcode(for barcode: String, completion: @escaping (NutritionInfo?) -> Void) {
        guard
            let code = barcode.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
            let url = URL(string:
                "https://api.nal.usda.gov/fdc/v1/foods/search?" +
                "api_key=\(apiKey)&query=\(code)&dataType=Branded&pageSize=1")
        else {
            completion(nil)
            return
        }

        session.dataTask(with: url) { data, _, error in
            guard error == nil, let data = data else {
                DispatchQueue.main.async { completion(nil) }
                return
            }
            do {
                let root = try JSONDecoder().decode(FDCSearchResponse.self, from: data)
                guard let first = root.foods.first,
                      let energy = first.foodNutrients.first(where: { $0.nutrientNumber == "208" })
                else {
                    DispatchQueue.main.async { completion(nil) }
                    return
                }
                let info = NutritionInfo(
                    fdcId: first.fdcId,
                    description: first.description,
                    caloriesPer100g: energy.value
                )
                DispatchQueue.main.async { completion(info) }
            } catch {
                DispatchQueue.main.async { completion(nil) }
            }
        }.resume()
    }
}

// MARK: — FDC JSON decoders —

private struct FDCSearchResponse: Codable {
    let foods: [FDCFood]
}

private struct FDCFood: Codable {
    let fdcId: Int
    let description: String
    let foodNutrients: [FDCNutrientEntry]
}

private struct FDCNutrientEntry: Codable {
    /// “208” → Energy (kcal)
    let nutrientNumber: String
    let value: Double

    private enum CodingKeys: String, CodingKey {
        case nutrientNumber, value
    }
}
