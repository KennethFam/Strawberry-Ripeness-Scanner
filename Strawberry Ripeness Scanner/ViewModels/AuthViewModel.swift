//
//  AuthViewModel.swift
//  Strawberry Ripeness Scanner
//
//  Created by Kenneth Pham on 2/26/25.
//

// handles form validation, networking for signing user in, updating login view, no account, wrong password

import Foundation
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage

// form validation protocol
protocol AuthenticationFormProtocol {
    var formIsValid: Bool { get }
}

@MainActor
class AuthViewModel: ObservableObject {
    @Published var userSession: FirebaseAuth.User?
    @Published var currentUser: User?
    @Published var cloudEnabledStatus = false {
        didSet {
            if !cloudEnabledStatus && userSession != nil {
                signOut()
            }
        }
    }
    
    init() {
        // ensures that user stays logged in unless they signed out
        cloudStatus()
        self.userSession = Auth.auth().currentUser
        
        Task {
            await fetchUser()
        }
    }
    
    func signIn(withEmail email: String, password: String) async throws {
        do {
            let result = try await Auth.auth().signIn(withEmail: email, password: password)
            self.userSession = result.user
            // remember to fetch user information otherwise app restart is required
            await fetchUser()
        } catch {
            print("DEBUG: Failed to log in with error \(error.localizedDescription)")
        }
    }
    
    func createUser(withEmail email: String, password: String, fullname: String) async throws {
        do {
            let result = try await Auth.auth().createUser(withEmail: email, password: password)
            self.userSession = result.user
            let user = User(id: result.user.uid, fullname: fullname, email: email, imagePaths: [String: String]())
            let encodedUser = try Firestore.Encoder().encode(user)
            try await Firestore.firestore().collection("users").document(user.id).setData(encodedUser)
            // fetch data from Firebase so that it can be displayed on screen
            await fetchUser()
        } catch {
            print("DEBUG: Failed to create user with error \(error.localizedDescription)")
        }
    }
    
    func signOut() {
        do {
            try Auth.auth().signOut() // signs out user on backend
            self.userSession = nil // wipes out user session and takes us back to login screen
            self.currentUser = nil // wipe out current user object b/c we don't want to hold on to user data when logging out
        } catch {
            print("DEBUG: Failed to sign out with error \(error.localizedDescription)")
        }
    }
    
    func deleteAccount() async {
        let user = Auth.auth().currentUser
        
        user?.delete { error in
          if let error = error {
              print("DEBUG: Failed to delete user. Error: \(error)")
              return
          } else {
              // set session variables to nil
              print("User successfully deleted.")
              self.userSession = nil
              self.currentUser = nil
          }
        }
    }
    
    private func fetchUser() async {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        guard let snapshot = try? await Firestore.firestore().collection("users").document(uid).getDocument() else { return }
        self.currentUser = try? snapshot.data(as: User.self)
        imagePathSync()
    }
    
    private func cloudStatus() {
        let cloudControlCollection = Firestore.firestore().collection("cloud_control")
        
        cloudControlCollection.document("on_off").addSnapshotListener { documentSnapshot, error in
            guard let document = documentSnapshot else {
              print("Error fetching document: \(error!)")
              return
            }
            guard let data = document.data() else {
                print("Document data was empty.")
                return
            }
            
            self.cloudEnabledStatus = data["enabled"] as! Bool
            print("Cloud Status: \(self.cloudEnabledStatus)")
        }
    }
    
    private func imagePathSync() {
        let userControlCollection = Firestore.firestore().collection("users")
        
        if let userID = currentUser?.id {
            userControlCollection.document(userID).addSnapshotListener { documentSnapshot, error in
                guard let snapshot = documentSnapshot else {
                  print("Error fetching user document for syncing: \(error!)")
                  return
                }
                
                do {
                    self.currentUser = try snapshot.data(as: User.self)
                } catch {
                    self.userSession = nil
                    self.currentUser = nil
                }
                
                print("User Sync Status: \(self.cloudEnabledStatus)")
            }
        }
    }
}
