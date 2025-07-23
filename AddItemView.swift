import SwiftUI

struct AddItemView: View {
  @EnvironmentObject private var pantryStore: PantryStore
  @Environment(\.dismiss)    private var dismiss

  let barcode: String
  let section: StorageSection

  @State private var name       = ""
  @State private var quantity   = 1
  @State private var expiryDate = Date()
  @State private var isStaple   = false

  var body: some View {
    NavigationStack {
      Form {
        Section("Barcode") {
          Text(barcode).foregroundColor(.secondary)
        }
        Section("Name") {
          TextField("Item name", text: $name)
            .onAppear { if name.isEmpty { name = barcode } }
        }
        Section("Quantity") {
          Stepper("\(quantity)", value: $quantity, in: 1...100)
        }
        Section("Expiry Date") {
          DatePicker("Expires on",
                     selection: $expiryDate,
                     displayedComponents: .date)
        }
        Section {
          Toggle("Mark as staple", isOn: $isStaple)
        }
        Section {
          Button("Save") {
            let newItem = PantryItem(
              id: UUID().uuidString,
              barcode: barcode,
              name: name.isEmpty ? barcode : name,
              imageName: "photo",
              quantity: quantity,
              expiryDate: expiryDate,
              isStaple: isStaple
            )
            pantryStore.add(newItem, to: section)
            dismiss()
          }
          .disabled(name.isEmpty)
        }
      }
      .navigationTitle("Add Item")
      .toolbar {
        ToolbarItem(placement: .cancellationAction) {
          Button("Cancel") { dismiss() }
        }
      }
    }
  }
}
