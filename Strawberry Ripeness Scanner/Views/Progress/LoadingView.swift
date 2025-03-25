//
//  LoadingView.swift
//  Strawberry Ripeness Scanner
//
//  Created by Kenneth Pham on 3/23/25.
//

import SwiftUI

struct LoadingView: View {
    var text: String
    var body: some View {
        ZStack {
            Color(.systemBackground)
                .ignoresSafeArea()
                .opacity(0.8)
            
            VStack {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .scaleEffect(3)
                    .padding(.top, 12)
                Text(text)
                    .padding(.top, 12)
                    .foregroundColor(.white)
            }
            .frame(width: 150, height: 150)
            .background(Color.black.aspectRatio(1.0, contentMode: .fill))
            .opacity(0.9)
            .cornerRadius(10)
        }
    }
}

#Preview {
    LoadingView(text: "Signing in...")
}
