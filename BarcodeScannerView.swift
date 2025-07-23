import SwiftUI
import VisionKit

struct BarcodeScannerView: UIViewControllerRepresentable {
    @Environment(\.dismiss) var dismiss
    var onScanned: (String) -> Void

    func makeCoordinator() -> Coordinator { Coordinator(self) }

    func makeUIViewController(context: Context) -> DataScannerViewController {
        // Note: initializer is non-throwing now, so no `try!`
        let scanner = DataScannerViewController(
            recognizedDataTypes: [.barcode()],
            qualityLevel: .balanced,
            recognizesMultipleItems: false,
            isHighFrameRateTrackingEnabled: false,
            isPinchToZoomEnabled: true,
            isGuidanceEnabled: true,
            isHighlightingEnabled: true
        )
        scanner.delegate = context.coordinator
        return scanner
    }

    func updateUIViewController(_ vc: DataScannerViewController, context: Context) {}

    class Coordinator: NSObject, DataScannerViewControllerDelegate {
        private let parent: BarcodeScannerView
        init(_ parent: BarcodeScannerView) { self.parent = parent }

        func dataScanner(
            _ scanner: DataScannerViewController,
            didAdd items: [RecognizedItem],
            allItems: [RecognizedItem]
        ) {
            for item in items {
                if case .barcode(let b) = item,
                   let code = b.payloadStringValue
                {
                    parent.onScanned(code)
                    parent.dismiss()
                    break
                }
            }
        }
    }
}
