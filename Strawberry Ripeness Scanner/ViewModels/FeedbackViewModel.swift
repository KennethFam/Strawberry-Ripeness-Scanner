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
    @Published var feedbackError = false
    @Published var contactError = false
    
    func uploadFeedback(_ image: MyImage, feedback: String, email: String, userID: String, completion: (() -> Void)? = nil) {
        self.loading = true
        
        let feedbackID = UUID()
        let feedbackDate = Date()
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
            "Unripe": String(image.unripe),
            "Rottent": String(image.rotten)
        ]

        
        let _ = fileRef.putData(imageData!, metadata: metadata) { (metadata, error) in
            // check for errors
            if error == nil && metadata != nil {
                print("Feedback submitted successfully!\n")
            } else {
                self.feedbackError = true
                print("Feedback submission failed!\n")
            }
            
            self.loading = false
            
            // .putData is asynchronous so use completion function to signify uploadPhoto is done and to execute its completion
            completion?()
        }
    }
    
    func uploadIssue(_ issue: String, subject: String, email: String, userID: String) async throws {
        Task { @MainActor in
            self.loading = true
        }
        let ticketID = UUID()
        let ticketDate = Date()
        let db = Firestore.firestore()
        
        do {
            defer {
                Task { @MainActor in
                    self.loading = false
                }
            }
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
            contactError = true
            print("Error writing document: \(error)")
        }
    }
}
