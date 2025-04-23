//
//  RipenessGuideView.swift
//  Strawberry Ripeness Scanner
//
//  Created by Kenneth Pham on 4/16/25.
//

import SwiftUI

struct RipenessGuideView: View {
    @Binding var path: [ScanPath]
    let ripeText = """
    A ripe strawberry is good to eat and good to harvest and ship. Beware, there is a chance that a ripe strawberry may become overripe or rotten during transit.
    """
    let nearlyRipeText = """
    A nearly ripe strawberry is not yet good to eat but good to harvest and ship.
    """
    let unripeText = """
    An unripe strawberry is not yet good to eat or harvest and ship.
    """
    let rottenText = """
    A rotten strawberry is not good to eat or harvest and ship. It should be disposed of.
    """
    var body: some View {
        ScrollView { // makes view scrollable
            VStack(spacing: 10){
                PageTitle(title: "Ripeness Guide")
                
                Guide(className: "Ripe", text: ripeText, image: "ripe")
                Guide(className: "Nearly Ripe", text: nearlyRipeText, image: "nearly_ripe")
                Guide(className: "Unripe", text: unripeText, image: "unripe")
                Guide(className: "Rotten", text: rottenText, image: "rotten")
                
                NavigationLink(value: ScanPath.tutorial) {
                    HStack(spacing: 3) {
                        Text("Dont know how to use the app?")
                        Text("View the tutorial!")
                            .fontWeight(.bold)
                    }
                    .font(.system(size: 14))
                }
                
                Spacer()
            }
        }
    }
}

//#Preview {
//    RipenessGuideView()
//}
