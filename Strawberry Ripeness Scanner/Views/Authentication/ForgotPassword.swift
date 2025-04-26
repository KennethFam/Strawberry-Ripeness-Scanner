//
//  ForgotPassword.swift
//  Strawberry Ripeness Scanner
//
//  Created by Kenneth Pham on 4/26/25.
//

//
//  AccountView.swift
//  Strawberry Ripeness Scanner
//
//  Created by Kenneth Pham on 2/24/25.
//

import SwiftUI
import UIKit

struct ForgotPassword: View {
    @State private var email = ""
    @State var goodEmail = false
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var viewModel: AuthViewModel
    
    var body: some View {
        NavigationStack {
            ZStack {
                VStack {
                    // Image
                    Image("LoginIcon")
                        .resizable()
                        .scaledToFill()
                        .frame(width: 100, height: 120)
                        .padding(.vertical, 32)
                    
                    // Form Fields
                    VStack(spacing: 24) {
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
                       
                        if viewModel.passResetError == true {
                            Text("An error occured. Please try again.")
                                .foregroundColor(Color(.systemRed))
                                .font(.subheadline)
                                .frame(maxWidth: UIScreen.main.bounds.width - 32, alignment: .leading)
                                .padding(.top, -20)
                                .padding(.bottom, -20)
                        }
                        if viewModel.cloudEnabledStatus == false {
                            Text("Server is currently down for maintenance")
                                .foregroundColor(Color(.systemRed))
                                .font(.subheadline)
                                .frame(maxWidth: UIScreen.main.bounds.width - 32, alignment: .leading)
                                .padding(.top, -20)
                                .padding(.bottom, -20)
                        }
                        
                    }
                    .padding(.horizontal)
                    .padding(.top, 12)
                    
                    // Login Button
                    Button {
                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                        viewModel.passResetError = false
                        viewModel.forgotPassword(email, completion: {
                            if !viewModel.passResetError {
                                dismiss()
                            }
                        })
                    } label: {
                        HStack {
                            Text("SEND")
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
                    
                    Button {
                        dismiss()
                    } label: {
                        Text("Cancel")
                            .font(.system(size: 14))
                    }
                    
                    Spacer()
                }
                if viewModel.loading {
                    LoadingView(text: "Sending...")
                }
            }
        }
    }
}

// form validation extension
extension ForgotPassword: AuthenticationFormProtocol {
    var formIsValid: Bool {
        return !email.isEmpty
        && validEmail(email)
        && viewModel.cloudEnabledStatus
    }
    
    func validEmail(_ email: String) -> Bool {
        let emailRegex  = "^[A-Z0-9._%+-]+@[A-Z0-9.-]+\\.[A-Z]{2,64}$"
        let emailPredicate = NSPredicate(format: "SELF MATCHES[c] %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
}

#Preview {
    ForgotPassword()
        .environmentObject(AuthViewModel())
}
