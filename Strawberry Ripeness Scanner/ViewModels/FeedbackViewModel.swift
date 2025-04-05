//
//  FeedbackViewModel.swift
//  Strawberry Ripeness Scanner
//
//  Created by Kenneth Pham on 3/27/25.
//

import SwiftUI
import FirebaseStorage


enum ScanPath {
    case feedback
}

class FeedbackViewModel: ObservableObject {
    @Published var path = [ScanPath]()
    @Published var loading = false
    
    func uploadFeedback(_ image: MyImage, feedback: String, email: String, userID: String, completion: (() -> Void)? = nil) {
        let feedbackID = UUID()
        let feedbackDate = Date()
        loading = true
        // create storage reference
        let storage = Storage.storage().reference()
        
        // turn image into data
        let imageData = image.image.jpegData(compressionQuality: 0.8)
        
        guard imageData != nil else {
            return
        }
        
        //specify the file path and name
        let fileRef = storage.child("Feedback/\(feedbackID).jpg")
        
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        metadata.customMetadata = [
            "User ID": userID,
            "Email": email,
            "Image ID": "\(image.id)",
            "Feedback": feedback.trimmingCharacters(in: .whitespacesAndNewlines),
            "Feedback Date": "\(feedbackDate)",
            "App Version": AppData.version,
            "Upload Date": "\(image.date)",
            "Ripe": String(image.ripe),
            "Nearly Ripe": String(image.nearlyRipe),
            "Unripe": String(image.unripe)
        ]

        
        let _ = fileRef.putData(imageData!, metadata: metadata) { (metadata, error) in
            // check for errors
            if error == nil && metadata != nil {
                print("Feedback submitted successfully!\n")
            }
            // .putData is asynchronous so use completion function to signify uploadPhoto is done and to execute its completion
            completion?()
        }
    }
}
