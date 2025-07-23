// Views/RecipesView.swift

import SwiftUI

struct RecipesView: View {
  @EnvironmentObject private var pantryStore: PantryStore
  @State private var recipes: [Recipe] = []
  @State private var onlyExpiring = false
  @State private var errorMessage: String?

  private var availableIngredients: [String] {
    pantryStore.pantryItems.map(\.name)
  }

  var body: some View {
    NavigationStack {
      VStack(spacing:16) {
        Toggle("Use items expiring soon only", isOn: $onlyExpiring)
          .padding(.horizontal)

        Button("Generate Recipes") {
          errorMessage = nil
          Task {
            do {
              recipes = try await OpenAIService
                .shared
                .generateRecipes(from: availableIngredients,
                                 onlyExpiring: onlyExpiring)
            } catch {
              errorMessage = error.localizedDescription
            }
          }
        }
        .buttonStyle(.borderedProminent)
        .padding(.horizontal)

        if let msg = errorMessage {
          Text(msg)
            .foregroundColor(.red)
            .multilineTextAlignment(.center)
            .padding(.horizontal)
        }

        ScrollView {
          LazyVGrid(columns: [GridItem(.adaptive(minimum:160))],
                    spacing: 16) {
            ForEach(recipes) { recipe in
              NavigationLink {
                RecipeDetailView(recipe: recipe)
              } label: {
                VStack(alignment:.leading, spacing:0) {
                  // if you have real images you can load them,
                  // or just a placeholder:
                  Image(systemName:"book.fill")
                    .resizable()
                    .scaledToFill()
                    .frame(height:120)
                    .clipped()
                    .cornerRadius(8)
                  Text(recipe.title)
                    .font(.headline)
                    .padding(8)
                }
                .background(.ultraThinMaterial,
                            in: RoundedRectangle(cornerRadius:12))
              }
            }
          }
          .padding()
        }
      }
      .navigationTitle("Recipes")
    }
  }
}
