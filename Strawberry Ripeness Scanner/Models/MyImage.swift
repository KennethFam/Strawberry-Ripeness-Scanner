//
//  MyImag.swift
//  Strawberry Ripeness Scanner
//
//  Created by Kenneth Pham on 1/24/25.
//

import UIKit

struct MyImage: Identifiable, Codable {
    var id = UUID()
    let date: Date 
    var ripe = 0
    var unripe = 0
    var nearlyRipe = 0
    var rotten = 0
    
    var image: UIImage {
        do {
            return try FileManager().readImage(with: id)
        } catch {
            return UIImage(systemName: "photo.fill")!
        }
    }
}
