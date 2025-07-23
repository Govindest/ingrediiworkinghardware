// GroupRecipesView.swift
import SwiftUI
import FirebaseFirestore    // if you’re talking to Firestore here
// …any other imports you need…

struct GroupRecipesView: View {
  @EnvironmentObject private var communityStore: CommunityStore
  @State private var recipes: [Recipe] = []
  @State private var errorMessage: String?

  var body: some View {
    NavigationStack {
      VStack(spacing: 16) {
        Button("Generate Group Recipes") {
          errorMessage = nil
          Task {
            do {
              // pull every member’s pantry item names
              let names = communityStore.combinedItems.map(\.name)
              recipes = try await OpenAIService.shared.generateRecipes(
                from: names,
                onlyExpiring: false
              )
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
            .padding()
        }

        ScrollView {
          LazyVGrid(columns: [GridItem(.adaptive(minimum: 160))], spacing: 16) {
            ForEach(recipes) { recipe in
              NavigationLink {
                RecipeDetailView(recipe: recipe)
              } label: {
                VStack {
                  Text(recipe.title)
                    .font(.headline)
                  // You could add an image or calories here
                }
                .padding()
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
              }
            }
          }
          .padding()
        }
      }
      .navigationTitle("Group Recipes")
    }
  }
}
