//
//  ButtonLabel.swift
//  Strawberry Ripeness Scanner
//
//  Created by Kenneth Pham on 1/24/25.
//

import SwiftUI

struct ButtonLabel: View {
    let symbolName: String
    let label: String
    var body: some View {
        HStack {
            Image(systemName: symbolName)
            Text(label)
        }
        .font(.headline)
        .padding()
        .frame(height: 40)
        .background(Color.blue)
        .foregroundColor(.white)
        .cornerRadius(15)
    }
}
// used to get preview of button design
#Preview {
    ButtonLabel(symbolName: "camera", label: "Camera")
}
