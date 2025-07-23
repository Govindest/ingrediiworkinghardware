// Views/RecipeDetailView.swift

import SwiftUI

struct RecipeDetailView: View {
  let recipe: Recipe

  var body: some View {
    ScrollView {
      VStack(alignment:.leading, spacing:16) {
        Text("Ingredients")
          .font(.headline)

        ForEach(recipe.ingredients, id:\.self) { ing in
          Text("• \(ing)")
            .font(.subheadline)
        }

        if let cal = recipe.calories {
          Divider()
          Text("Calories: \(cal) kcal")
            .font(.subheadline)
            .foregroundColor(.secondary)
        }
      }
      .padding()
    }
    .navigationTitle(recipe.title)
  }
}
