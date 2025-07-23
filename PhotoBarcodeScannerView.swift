import SwiftUI
import UIKit
import Vision

struct PhotoBarcodeScannerView: UIViewControllerRepresentable {
    @Environment(\.dismiss) var dismiss
    var onScanned: (String) -> Void

    func makeCoordinator() -> Coordinator { Coordinator(self) }

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.cameraCaptureMode = .photo
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        private let parent: PhotoBarcodeScannerView
        init(_ parent: PhotoBarcodeScannerView) { self.parent = parent }

        func imagePickerController(
            _ picker: UIImagePickerController,
            didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
        ) {
            picker.dismiss(animated: true)

            guard let uiImage = info[.originalImage] as? UIImage,
                  let cgImage = uiImage.cgImage
            else {
                parent.dismiss()
                return
            }

            let request = VNDetectBarcodesRequest { [weak self] request, error in
                guard let self = self,
                      error == nil,
                      let result = request.results?.first as? VNBarcodeObservation,
                      let code = result.payloadStringValue
                else {
                    DispatchQueue.main.async {
                        self?.parent.dismiss()
                    }
                    return
                }
                DispatchQueue.main.async {
                    self.parent.onScanned(code)
                    self.parent.dismiss()
                }
            }

            let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
            DispatchQueue.global(qos: .userInitiated).async {
                try? handler.perform([request])
            }
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true)
            parent.dismiss()
        }
    }
}
