//
//  NetworkMonitor.swift
//  Strawberry Ripeness Scanner
//
//  Created by Kenneth Pham on 4/23/25.
//

import SwiftUI
import Network

class NetworkMonitor: ObservableObject {
    @Published var connected = false
    let monitor = NWPathMonitor()
    let queue = DispatchQueue(label: "Network Monitor")
    
    init() {
        // monitor works on queue separate from main thread
        monitor.pathUpdateHandler = { path in
            // change connected on main queue b/c it's a Published property, and changes should be displayed right away
            // check for wifi, cellular, and ethernet specifically b/c path.status could be satisfied by conditions other than an actually network condition
            DispatchQueue.main.async {
                let wifi = path.usesInterfaceType(.wifi)
                let cellular = path.usesInterfaceType(.cellular)
                let ethernet = path.usesInterfaceType(.wiredEthernet)
                self.connected = wifi || cellular || ethernet
                print("Connection Status: \(self.connected)")
            }
        }
        monitor.start(queue: queue)
    }
}
