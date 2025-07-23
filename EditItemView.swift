// Views/EditItemView.swift

import SwiftUI

struct EditItemView: View {
  @Environment(\.dismiss) private var dismiss
  @Binding var item: PantryItem

  var body: some View {
    Form {
      Section("Name & Quantity") {
        TextField("Item name", text: $item.name)
        Stepper("Quantity: \(item.quantity)",
                value: $item.quantity, in: 1...100)
      }

      Section("Expiry Date") {
        DatePicker("Expires on",
                   selection: $item.expiryDate,
                   displayedComponents: .date)
      }

      Section {
        Toggle("Staple item", isOn: $item.isStaple)
      }

      Section {
        Button("Done") {
          dismiss()
        }
      }
    }
    .navigationTitle("Edit Item")
  }
}
