//
//  NetworkMonitor.swift
//  Strawberry Ripeness Scanner
//
//  Created by Kenneth Pham on 4/23/25.
//

import SwiftUI
import Network

class NetworkMonitor: ObservableObject {
    @Published var connected = true
    let monitor = NWPathMonitor()
    let queue = DispatchQueue(label: "Network Monitor")
    
    init() {
        // monitor works on queue separate from main thread
        monitor.pathUpdateHandler = { path in
            // change connected on main queue b/c it's a Published property, and changes should be displayed right away
            if path.status == .satisfied {
                DispatchQueue.main.async {
                    self.connected = true
                }
            }
            else {
                DispatchQueue.main.async {
                    self.connected = false
                }
            }
        }
        monitor.start(queue: queue)
    }
}
