//
//  ButtonLabel.swift
//  Strawberry Ripeness Scanner
//
//  Created by Kenneth Pham on 1/24/25.
//

import SwiftUI

struct ButtonLabel: View {
    var symbolName: String?
    var text: String?
    var clicked: (() -> Void)
    var body: some View {
        Button (action: clicked) {
            if let symbolName = symbolName {
                Image(systemName: symbolName)
                    .font(.system(size: 30))
            }
            if let text = text {
                Text(text)
                    .fontWeight(.bold)
            }
        }
    }
}
// used to get preview of button design
#Preview {
    ButtonLabel(symbolName: "camera") { print("Clicked!") }
}
