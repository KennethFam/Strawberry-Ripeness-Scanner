//
//  FeedbackViewModel.swift
//  Strawberry Ripeness Scanner
//
//  Created by Kenneth Pham on 3/27/25.
//

import SwiftUI
import FirebaseStorage
import FirebaseFirestore

class FeedbackViewModel: ObservableObject {
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
            "Feedback ID": "\(feedbackID)",
            "User ID": userID,
            "Email": email,
            "Image ID": "\(image.id)",
            "Feedback Date": "\(feedbackDate)",
            "Feedback": feedback.trimmingCharacters(in: .whitespacesAndNewlines),
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
    
    func uploadIssue(_ issue: String, subject: String, email: String, userID: String) async throws {
        let ticketID = UUID()
        let ticketDate = Date()
        let db = Firestore.firestore()
        
        do {
            try await db.collection("support_tickets").document("\(ticketID)").setData([
            "Ticket ID": "\(ticketID)",
            "User ID": userID,
            "Email": email,
            "Ticket Date": "\(ticketDate)",
            "Subject": subject,
            "Issue": issue,
            "App Version": AppData.version
            ])
            print("Document successfully written!")
        } catch {
            print("Error writing document: \(error)")
        }
    }
}
