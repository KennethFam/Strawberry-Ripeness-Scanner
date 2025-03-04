//
//  SettingsRowView.swift
//  Strawberry Ripeness Scanner
//
//  Created by Kenneth Pham on 2/25/25.
//

import SwiftUI

struct SettingsRowView: View {
    var imageName: String?
    let title: String
    let tintColor: Color
    var textColor = Color(.black)
    
    var body: some View {
        HStack(spacing: 12) {
            if let imageName = imageName {
                Image(systemName: imageName)
                    .imageScale(.small)
                    .font(.title)
                    .foregroundColor(tintColor)
            }
            
            Text(title)
                .font(.subheadline)
                .foregroundColor(textColor)
        }
    }
}

#Preview {
    SettingsRowView(imageName: "gear", title: "Version", tintColor: Color(.systemGray))
}
