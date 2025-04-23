//
//  Guide.swift
//  Strawberry Ripeness Scanner
//
//  Created by Kenneth Pham on 4/22/25.
//

import SwiftUI

struct Guide: View {
    let className: String
    let text: String
    let image: String
    var body: some View {
        VStack(spacing: 0) {
            Text("\(className):")
                .font(.system(size: 24, weight: .bold))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading, 16)
            Text(text)
                .font(.system(size: 14))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading, 16)
            Image(image)
                .resizable()
                .scaledToFill()
        }
    }
}
