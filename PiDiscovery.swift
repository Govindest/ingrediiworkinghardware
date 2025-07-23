// Models/PiDiscovery.swift
import Foundation
import Network

class PiDiscovery: ObservableObject {
  @Published var services: [NWBrowser.Result] = []
  private var browser: NWBrowser?

  init() {
    let params = NWParameters.tcp
    let browser = NWBrowser(
      for: .bonjour(type: "_mjpeg._tcp", domain: nil),
      using: params
    )
    browser.browseResultsChangedHandler = { results, _ in
      DispatchQueue.main.async {
        self.services = Array(results)
      }
    }
    browser.start(queue: .main)
    self.browser = browser
  }

  deinit { browser?.cancel() }
}
