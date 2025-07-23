// Views/CommunityDetailView.swift

import SwiftUI

struct CommunityDetailView: View {
  /// Inject the same CommunityStore you used upstream.
  @EnvironmentObject private var communityStore: CommunityStore

  /// Which member’s UID we’re looking at
  let memberUID: String

  /// Safely pull out that member’s pantry (or empty array)
  private var items: [PantryItem] {
    communityStore.memberPantries[memberUID] ?? []
  }

  var body: some View {
    List {
      ForEach(items) { item in
        PantryRowView(item: item)
      }
    }
    .navigationTitle("Friend’s Pantry")
  }
}
