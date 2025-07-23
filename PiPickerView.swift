// Views/PiPickerView.swift

import SwiftUI
import Network  // for NWBrowser

struct PiPickerView: View {
    @Environment(\.dismiss)    private var dismiss
    @EnvironmentObject         private var piDiscovery: PiDiscovery
    @AppStorage("piStreamURL") private var piURL: String = ""

    var body: some View {
        NavigationView {
            List {
                // We only want the bonjour _mjpeg._tcp services
                ForEach(piDiscovery.services, id: \.endpoint) { result in
                    // result.endpoint is an NWEndpoint
                    if case let .service(name: name,
                                         type: _,
                                         domain: domain,
                                         interface: _) = result.endpoint
                    {
                        // Display name.domain, e.g. "Pi Camera on raspberrypi.local"
                        let host = "\(name).\(domain)"
                        Button(host) {
                            // mjpg-streamer default port is 8080:
                            piURL = "http://\(host):8080/?action=stream"
                            dismiss()
                        }
                    }
                }
            }
            .navigationTitle("Select Pi Camera")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", role: .cancel) { dismiss() }
                }
            }
        }
    }
}
