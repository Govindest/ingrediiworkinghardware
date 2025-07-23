// Views/ModeAwareBarcodeScannerView.swift

import SwiftUI
import AVFoundation

struct ModeAwareBarcodeScannerView: UIViewControllerRepresentable {
  @Binding var isAddMode: Bool
  var onCode: (String) -> Void

  func makeCoordinator() -> Coordinator {
    Coordinator(isAddMode: $isAddMode, onCode: onCode)
  }

  func makeUIViewController(context: Context) -> ScannerVC {
    let vc = ScannerVC()
    vc.delegate = context.coordinator
    return vc
  }

  func updateUIViewController(_ uiViewController: ScannerVC, context: Context) {
    // no stateful updates needed here
  }

  // ──────────────────────────────────────────────────────────
  class Coordinator: NSObject {
    var isAddMode: Binding<Bool>
    var onCode: (String) -> Void
    private var wasCovered = false

    init(isAddMode: Binding<Bool>, onCode: @escaping (String)->Void) {
      self.isAddMode = isAddMode
      self.onCode    = onCode
    }

    func didDetect(code: String) {
      DispatchQueue.main.async {
        self.onCode(code)
      }
    }

    func didMeasureLuma(_ luma: UInt) {
      let covered = luma < 25     // you can tweak this threshold
      if covered != wasCovered {
        wasCovered = covered
        DispatchQueue.main.async {
          self.isAddMode.wrappedValue.toggle()
        }
      }
    }
  }

  class ScannerVC: UIViewController,
                   AVCaptureMetadataOutputObjectsDelegate,
                   AVCaptureVideoDataOutputSampleBufferDelegate {
    var delegate: Coordinator?

    private let session         = AVCaptureSession()
    private let metaOutput      = AVCaptureMetadataOutput()
    private let videoDataOutput = AVCaptureVideoDataOutput()

    override func viewDidLoad() {
      super.viewDidLoad()

      guard let device = AVCaptureDevice.default(
              .builtInWideAngleCamera,
              for: .video,
              position: .back),
            let input = try? AVCaptureDeviceInput(device: device)
      else { return }

      session.beginConfiguration()
      session.sessionPreset = .high

      // — Metadata (barcode) output
      if session.canAddInput(input), session.canAddOutput(metaOutput) {
        session.addInput(input)
        session.addOutput(metaOutput)
        metaOutput.setMetadataObjectsDelegate(self, queue: .main)
        metaOutput.metadataObjectTypes = [
          .ean8, .ean13, .upce, .qr, .code128
        ]
      }

      // — VideoData (for brightness / “cover” detection)
      if session.canAddOutput(videoDataOutput) {
        session.addOutput(videoDataOutput)
        let queue = DispatchQueue(label: "video.luma.queue")
        videoDataOutput.setSampleBufferDelegate(self, queue: queue)
        videoDataOutput.videoSettings = [
          kCVPixelBufferPixelFormatTypeKey as String:
            kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange
        ]
      }

      // — Preview layer
      let preview = AVCaptureVideoPreviewLayer(session: session)
      preview.frame = view.bounds
      preview.videoGravity = .resizeAspectFill
      view.layer.addSublayer(preview)

      session.commitConfiguration()
      session.startRunning()
    }

    // MARK: Metadata delegate
    func metadataOutput(_ output: AVCaptureMetadataOutput,
                        didOutput objects: [AVMetadataObject],
                        from connection: AVCaptureConnection) {
      for o in objects {
        guard let bar = o as? AVMetadataMachineReadableCodeObject,
              let str = bar.stringValue
        else { continue }
        delegate?.didDetect(code: str)
        break
      }
    }

    // MARK: Video‐data delegate (brightness)
    func captureOutput(_ output: AVCaptureOutput,
                       didOutput sampleBuffer: CMSampleBuffer,
                       from connection: AVCaptureConnection) {
      guard let buf = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
      CVPixelBufferLockBaseAddress(buf, .readOnly)
      let w = CVPixelBufferGetWidthOfPlane(buf, 0)
      let h = CVPixelBufferGetHeightOfPlane(buf, 0)
      let rowBytes = CVPixelBufferGetBytesPerRowOfPlane(buf, 0)
      let base = CVPixelBufferGetBaseAddressOfPlane(buf, 0)!
                      .assumingMemoryBound(to: UInt8.self)

      var sum: UInt = 0, count: UInt = 0
      for y in stride(from: 0, to: h, by: 10) {
        let row = base + y * rowBytes
        for x in stride(from: 0, to: w, by: 10) {
          sum += UInt(row[x])
          count += 1
        }
      }
      CVPixelBufferUnlockBaseAddress(buf, .readOnly)

      let avg = sum / count
      delegate?.didMeasureLuma(avg)
    }
  }
}
