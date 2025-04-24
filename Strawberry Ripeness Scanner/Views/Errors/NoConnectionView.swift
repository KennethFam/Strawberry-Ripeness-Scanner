//
//  NoConnectionView.swift
//  Strawberry Ripeness Scanner
//
//  Created by Kenneth Pham on 4/24/25.
//

import SwiftUI

struct NoConnectionView: View {
    var body: some View {
        VStack(spacing: 0) {
            Image(systemName: "wifi.exclamationmark.circle")
                .font(.system(size: 35))
                .foregroundColor(.red)
            Text("No internet connection.")
                .font(.system(size: 14))
                .foregroundColor(.red)
        }
    }
}
