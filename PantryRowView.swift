import SwiftUI

struct PantryRowView: View {
  let item: PantryItem

  var body: some View {
    HStack {
      Text(item.name)
      Spacer()
      Text("×\(item.quantity)")
        .foregroundColor(.secondary)
    }
    .padding(.vertical, 4)
  }
}
