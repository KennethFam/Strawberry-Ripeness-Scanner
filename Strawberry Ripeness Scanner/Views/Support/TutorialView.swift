//
//  TutorialView.swift
//  Strawberry Ripeness Scanner
//
//  Created by Kenneth Pham on 4/16/25.
//

import SwiftUI

struct TutorialView: View {
    @Binding var path: [ScanPath]
    var body: some View {
        VStack(spacing: 10) {
            PageTitle(title: "Tutorial View")
            NavigationLink(value: ScanPath.ripenessGuide) {
                HStack(spacing: 3) {
                    Text("Ripeness Guide")
                        .fontWeight(.bold)
                }
                .font(.system(size: 14))
            }
            Spacer()
        }
    }
}
