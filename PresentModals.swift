import SwiftUI

struct PresentModals: View {
    @EnvironmentObject private var pantryStore: PantryStore

    @Binding var showLiveScanner: Bool
    @Binding var showPhotoScanner: Bool
    @Binding var showPiScanner: Bool
    @Binding var showAddItem: Bool
    @Binding var isAddMode: Bool

    let selectedSection: StorageSection
    let handleBarcode: (String) -> Void

    var body: some View {
        EmptyView()
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
                // ← use `section:` here
                AddItemView(barcode: "", section: selectedSection)
                    .environmentObject(pantryStore)
            }
    }
}
