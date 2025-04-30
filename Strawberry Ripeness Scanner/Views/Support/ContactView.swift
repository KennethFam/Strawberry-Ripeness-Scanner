//
//  ContactView.swift
//  Strawberry Ripeness Scanner
//
//  Created by Kenneth Pham on 4/16/25.
//

import SwiftUI

struct ContactView: View {
    @EnvironmentObject var viewModel: AuthViewModel
    @EnvironmentObject var fbvm: FeedbackViewModel
    @EnvironmentObject var nm: NetworkMonitor
    @Binding var path: [ScanPath]
    @State var email = ""
    @State var subject = ""
    @State var issue = ""
    @State var goodEmail = false
    var body: some View {
        if nm.connected == false {
            NoConnectionView()
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        if path.count > 1 {
                            Button {
                                path.removeAll()
                            } label: {
                                Image(systemName: "house.fill")
                            }
                        }
                    }
                }
        } else {
            ZStack {
                VStack {
                    Image("LoginIcon")
                        .resizable()
                        .scaledToFill()
                        .frame(width: 100, height: 120)
                        .padding(.vertical, 32)
                    
                    VStack(spacing: 24) {
                        if viewModel.currentUser == nil {
                            InputView(text: $email,
                                      title: "Email",
                                      placeholder: "name@example.com")
                            .autocapitalization(.none)
                            .onChange(of: email) {
                                goodEmail = validEmail(email)
                            }
                            if !email.isEmpty && !goodEmail {
                                Text("Invalid Email")
                                    .foregroundColor(Color(.systemRed))
                                    .font(.subheadline)
                                    .frame(maxWidth: UIScreen.main.bounds.width - 32, alignment: .leading)
                                    .padding(.top, -20)
                            }
                        }
                        InputView(text: $subject,
                                  title: "Subject",
                                  placeholder: "Feedback, Account, etc.")
                        
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Issue:")
                                .foregroundColor(Color(.darkGray))
                                .fontWeight(.semibold)
                                .font(.footnote)
                            
                            TextField("Type your issue here...", text: $issue, axis: .vertical)
                                .padding(10)
                                .frame(maxWidth: .infinity)
                                .lineLimit(5...)
                                .font(.system(size: 14))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color.black, lineWidth: 1)
                                )
                        }
                        
                        if fbvm.contactError {
                            Text("An error occurred. Please try again.")
                                .foregroundColor(Color(.systemRed))
                                .font(.subheadline)
                        }
                        if viewModel.cloudEnabledStatus == false {
                            Text("Server is currently down for maintenance")
                                .foregroundColor(Color(.systemRed))
                                .font(.subheadline)
                        }
                        
                    }
                    .padding(.horizontal)
                    .padding(.top, 12)
                    
                    Button {
                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                        fbvm.contactError = false
                        Task {
                            defer {
                                if fbvm.contactError == false {
                                    path.removeLast()
                                }
                            }
                            try await fbvm.uploadIssue(issue, subject: subject, email: email, userID: viewModel.currentUser?.id ?? "")
                        }
                    } label: {
                        HStack {
                            Text("SUBMIT")
                                .fontWeight(.semibold)
                        }
                        .foregroundColor(Color(.white))
                        // takes width of screen - 32 pixels
                        .frame(width: UIScreen.main.bounds.width - 32, height: 48)
                    }
                    .background(Color(.systemBlue))
                    .cornerRadius(10)
                    .padding(.top, 24)
                    .disabled(!formIsValid)
                    .opacity(formIsValid ? 1.0 : 0.5)
                    
                    Spacer()
                }
                .onTapGesture {
                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                }
                .onAppear {
                    if let user = viewModel.currentUser {
                        email = user.email
                    }
                }
                if fbvm.loading {
                    LoadingView(text: "Submitting ticket...")
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    if path.count > 1 {
                        Button {
                            path.removeAll()
                        } label: {
                            Image(systemName: "house.fill")
                        }
                    }
                }
            }
        }
    }
}

extension ContactView {
    var formIsValid: Bool {
        return !email.isEmpty
        && validEmail(email)
        && viewModel.cloudEnabledStatus
        && !subject.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        && !issue.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    func validEmail(_ email: String) -> Bool {
        let emailRegex  = "^[A-Z0-9._%+-]+@[A-Z0-9.-]+\\.[A-Z]{2,64}$"
        let emailPredicate = NSPredicate(format: "SELF MATCHES[c] %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
}
