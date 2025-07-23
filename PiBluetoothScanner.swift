// Models/PiBluetoothScanner.swift

import Foundation
import CoreBluetooth

class PiBluetoothScanner: NSObject, ObservableObject {
  @Published var latestCode: String?

  private var central: CBCentralManager!
  private var piPeripheral: CBPeripheral?
  private var barcodeChar: CBCharacteristic?

  // Match your SERVICE_UUID / CHAR_UUID
  private let serviceUUID = CBUUID(string: "12345678-1234-5678-1234-56789abcdef0")
  private let charUUID    = CBUUID(string: "12345678-1234-5678-1234-56789abcdef1")

  override init(){
    super.init()
    central = CBCentralManager(delegate: self, queue: nil)
  }
}

extension PiBluetoothScanner: CBCentralManagerDelegate {
  func centralManagerDidUpdateState(_ c: CBCentralManager) {
    guard c.state == .poweredOn else { return }
    // start scanning for peripherals advertising our service
    central.scanForPeripherals(withServices: [serviceUUID], options: nil)
  }

  func centralManager(_ c: CBCentralManager,
                      didDiscover p: CBPeripheral,
                      advertisementData: [String:Any],
                      rssi: NSNumber) {
    piPeripheral = p
    p.delegate = self
    central.stopScan()
    central.connect(p, options: nil)
  }

  func centralManager(_ c: CBCentralManager,
                      didConnect p: CBPeripheral) {
    p.discoverServices([serviceUUID])
  }
}

extension PiBluetoothScanner: CBPeripheralDelegate {
  func peripheral(_ p: CBPeripheral,
                  didDiscoverServices error: Error?) {
    guard let svc = p.services?.first(where:{ $0.uuid == serviceUUID })
    else { return }
    p.discoverCharacteristics([charUUID], for: svc)
  }

  func peripheral(_ p: CBPeripheral,
                  didDiscoverCharacteristicsFor svc: CBService,
                  error: Error?) {
    guard let c = svc.characteristics?.first(where:{ $0.uuid == charUUID })
    else { return }
    barcodeChar = c
    p.setNotifyValue(true, for: c)
  }

  func peripheral(_ p: CBPeripheral,
                  didUpdateValueFor c: CBCharacteristic,
                  error: Error?) {
    if let data = c.value,
       let s = String(data: data, encoding: .utf8) {
      DispatchQueue.main.async {
        self.latestCode = s
      }
    }
  }
}
