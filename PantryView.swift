// Views/PantryView.swift

import SwiftUI

struct PantryView: View {
  @EnvironmentObject private var pantryStore: PantryStore
  @EnvironmentObject private var btScanner:    PiBluetoothScanner

  @State private var selectedSection: StorageSection = .pantry
  @State private var isAddMode         = true
  @State private var searchText        = ""
  @State private var showLiveScanner   = false
  @State private var showPhotoScanner  = false
  @State private var showPiScanner     = false
  @State private var showAddItem       = false

  private var items: [PantryItem] {
    switch selectedSection {
    case .pantry:  return pantryStore.pantryItems
    case .fridge:  return pantryStore.fridgeItems
    case .grocery: return pantryStore.groceryItems
    }
  }

  var body: some View {
    NavigationStack {
      List {
        HStack {
          Menu {
            Picker("", selection: $selectedSection) {
              ForEach(StorageSection.allCases) { section in
                Text(section.rawValue.capitalized).tag(section)
              }
            }
          } label: {
            Label(selectedSection.rawValue.capitalized,
                  systemImage: "chevron.down")
              .font(.headline)
          }
          .onChange(of: selectedSection) {
            pantryStore.updateCurrentSection($0)
          }

          Spacer()

          Button { isAddMode.toggle() } label: {
            Image(systemName: isAddMode ? "plus.circle" : "minus.circle")
              .font(.title2)
              .foregroundColor(isAddMode ? .green : .red)
          }
        }
        .padding(.vertical, 4)

        ForEach(items) { item in
          NavigationLink {
            EditItemView(item: binding(for: item, in: selectedSection))
              .environmentObject(pantryStore)
          } label: {
            PantryRowView(item: item)
          }
          .swipeActions {
            Button(role: .destructive) {
              pantryStore.remove(item, from: selectedSection)
            } label: {
              Label("Delete", systemImage: "trash")
            }
          }
        }
      }
      .searchable(text: $searchText,
                  prompt: "Search \(selectedSection.rawValue.capitalized)")
      .navigationTitle(selectedSection.rawValue.capitalized)
      .toolbar {
        ToolbarItem(placement: .navigationBarLeading) {
          Button { showLiveScanner = true }
          label: { Image(systemName: "barcode.viewfinder") }
        }
        ToolbarItem(placement: .navigationBarTrailing) {
          Button { showAddItem = true }
          label: { Label("Add", systemImage: "plus") }
        }
      }
      .onChange(of: btScanner.latestCode) { code in
        if let c = code { handleBarcode(c) }
      }
      .sheet(isPresented: $showLiveScanner) {
        ModeAwareBarcodeScannerView(isAddMode: $isAddMode) {
          handleBarcode($0)
        }
      }
      .sheet(isPresented: $showPhotoScanner) {
        PhotoBarcodeScannerView { handleBarcode($0) }
      }
      .sheet(isPresented: $showPiScanner) {
        PiBarcodeScannerView { handleBarcode($0) }
      }
      .sheet(isPresented: $showAddItem) {
        AddItemView(barcode: "", section: selectedSection)
          .environmentObject(pantryStore)
      }
    }
  }

  private func handleBarcode(_ code: String) {
    if isAddMode {
      NutritionAPI.shared.fetchNutritionByBarcode(for: code) { info in
        pantryStore.increment(
          barcode: code,
          info: info,
          in: selectedSection
        )
      }
    } else {
      pantryStore.decrement(barcode: code,
                            in: selectedSection)
    }
  }

  private func binding(
    for item: PantryItem,
    in section: StorageSection
  ) -> Binding<PantryItem> {
    switch section {
    case .pantry:
      let idx = pantryStore.pantryItems.firstIndex { $0.id == item.id }!
      return $pantryStore.pantryItems[idx]
    case .fridge:
      let idx = pantryStore.fridgeItems.firstIndex { $0.id == item.id }!
      return $pantryStore.fridgeItems[idx]
    case .grocery:
      let idx = pantryStore.groceryItems.firstIndex { $0.id == item.id }!
      return $pantryStore.groceryItems[idx]
    }
  }
}
