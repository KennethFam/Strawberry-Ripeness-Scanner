//
//  PageTitle.swift
//  Strawberry Ripeness Scanner
//
//  Created by Kenneth Pham on 4/22/25.
//

import SwiftUI

struct PageTitle: View {
    let title: String
    var body: some View {
        Text(title)
            .font(.system(size: 34, weight: .bold))
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.leading, 16)
    }
}
