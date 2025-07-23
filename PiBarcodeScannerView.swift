// Views/PiBarcodeScannerView.swift

import SwiftUI
import Combine
import Vision

/// Streams an MJPEG feed from your Pi, shows each frame,
/// and runs Vision’s barcode detector on it.
struct PiBarcodeScannerView: View {
    @Environment(\.dismiss) var dismiss
    @AppStorage("piStreamURL") private var urlString: String = ""

    /// Called when we detect a barcode payload
    var onScanned: (String) -> Void

    @State private var image: UIImage?
    @State private var dataCancellable: AnyCancellable?
    @State private var buffer = Data()

    var body: some View {
        VStack {
            if let ui = image {
                Image(uiImage: ui)
                    .resizable()
                    .scaledToFit()
            } else {
                ProgressView("Connecting…")
            }
        }
        .onAppear(perform: startStream)
        .onDisappear { dataCancellable?.cancel() }
    }

    private func startStream() {
        guard let url = URL(string: urlString) else { return }

        dataCancellable = URLSession.shared.dataTaskPublisher(for: url)
            .map(\.data)
            .sink(
                receiveCompletion: { _ in },
                receiveValue: parseMJPEG(data:)
            )
    }

    private func parseMJPEG(data newData: Data) {
        buffer.append(newData)

        // Look for JPEG start/end markers
        while
            let soi = buffer.range(of: Data([0xFF,0xD8])),
            let eoi = buffer.range(of: Data([0xFF,0xD9]), options: [], in: soi.lowerBound..<buffer.endIndex)
        {
            let jpg = buffer[soi.lowerBound..<eoi.upperBound]
            buffer.removeSubrange(0..<eoi.upperBound)

            if let ui = UIImage(data: jpg) {
                DispatchQueue.main.async {
                    self.image = ui
                    self.scanBarcode(in: ui)
                }
            }
        }
    }

    private func scanBarcode(in ui: UIImage) {
        guard let cg = ui.cgImage else { return }
        let req = VNDetectBarcodesRequest { req, _ in
            if let obs = req.results?.compactMap({ $0 as? VNBarcodeObservation }).first,
               let code = obs.payloadStringValue
            {
                DispatchQueue.main.async {
                    onScanned(code)
                    dismiss()
                }
            }
        }
        let handler = VNImageRequestHandler(cgImage: cg, options: [:])
        DispatchQueue.global(qos: .userInitiated).async {
            try? handler.perform([req])
        }
    }
}
