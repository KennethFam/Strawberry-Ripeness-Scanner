//
//  AccountView.swift
//  Strawberry Ripeness Scanner
//
//  Created by Kenneth Pham on 2/24/25.
//

import SwiftUI
import UIKit

struct LoginView: View {
    @State private var email = ""
    @State private var password = ""
    @State var goodEmail = false
    @EnvironmentObject var viewModel: AuthViewModel
    @EnvironmentObject var vm: ViewModel
    
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
                        
                        InputView(text: $password,
                                  title: "Password",
                                  placeholder: "Enter your password",
                                  isSecureField: true)
                        if viewModel.cloudEnabledStatus == false {
                            Text("Server is currently down for maintenance.")
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
                        viewModel.loading = true
                        Task {
                            try await viewModel.signIn(withEmail: email,
                                                       password: password)
                        }
                    } label: {
                        HStack {
                            Text("LOGIN")
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
                    
                    
                    // Sign-Up Button
                    NavigationLink {
                        RegistrationView()
                            .navigationBarBackButtonHidden(true)
                    } label: {
                        HStack(spacing: 3) {
                            Text("Dont have an account?")
                            Text("Sign Up")
                                .fontWeight(.bold)
                        }
                        .font(.system(size: 14))
                    }
                    
                    Spacer()
                }
                if viewModel.loading {
                    LoadingView(text: "Signing in...")
                }
            }
        }
    }
}

// form validation extension
extension LoginView: AuthenticationFormProtocol {
    var formIsValid: Bool {
        return !email.isEmpty
        && validEmail(email)
        && !password.isEmpty
        && password.count > 0
        && viewModel.cloudEnabledStatus
    }
    
    func validEmail(_ email: String) -> Bool {
        let emailRegex  = "^[A-Z0-9._%+-]+@[A-Z0-9.-]+\\.[A-Z]{2,64}$"
        let emailPredicate = NSPredicate(format: "SELF MATCHES[c] %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
}

#Preview {
    LoginView()
        .environmentObject(ViewModel())
}
