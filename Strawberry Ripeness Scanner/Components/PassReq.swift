//
//  PassReq.swift
//  Strawberry Ripeness Scanner
//
//  Created by Kenneth Pham on 4/25/25.
//

import SwiftUI

struct PassReq: View {
    let text: String
    @Binding var good: Bool
    
    var body: some View {
        HStack(spacing: 0) {
            Text("\(text) ")
            if good {
                Image(systemName: "checkmark")
                    .foregroundColor(.green)
            } else {
                Image(systemName: "xmark")
                    .foregroundColor(Color(.systemRed))
            }
        }
        .font(.subheadline)
        .frame(maxWidth: UIScreen.main.bounds.width - 32, alignment: .leading)
        .padding(.bottom, -20)
        .padding(.top, -20)
    }
}
