import SwiftUI

struct ItemsList: View {
    let items: [PantryItem]
    let selectedSection: StorageSection
    let bindingFor: (PantryItem) -> Binding<PantryItem>
    let removeAction: (PantryItem) -> Void

    var body: some View {
        ForEach(items) { item in
            NavigationLink {
                EditItemView(item: bindingFor(item))
                    // `PantryStore` is already injected upstream
            } label: {
                PantryRowView(item: item)
            }
            .swipeActions {
                Button(role: .destructive) {
                    removeAction(item)
                } label: {
                    Label("Delete", systemImage: "trash")
                }
            }
        }
    }
}
