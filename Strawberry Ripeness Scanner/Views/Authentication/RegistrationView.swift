//
//  RegistrationView.swift
//  Strawberry Ripeness Scanner
//
//  Created by Kenneth Pham on 2/25/25.
//

import SwiftUI

struct RegistrationView: View {
    @State private var email = ""
    @State private var fullname = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State var goodPass = false
    @State var goodEmail = false
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var viewModel: AuthViewModel
    @EnvironmentObject var vm: ViewModel
    
    var body: some View {
        ZStack {
            VStack {
                Image("LoginIcon")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 100, height: 120)
                    .padding(.vertical, 32)
                
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
                    
                    InputView(text: $fullname,
                              title: "Full Name",
                              placeholder: "Enter your name")
                    
                    ZStack(alignment: .trailing) {
                        InputView(text: $password,
                                  title: "Password",
                                  placeholder: "Enter your password",
                                  isSecureField: true)
                        .onChange(of: password) {
                            goodPass = validPass(password)
                        }
                        
                        if !password.isEmpty && !confirmPassword.isEmpty {
                            if password == confirmPassword {
                                Image(systemName: "checkmark.circle.fill")
                                    .imageScale(.large)
                                    .fontWeight(.bold)
                                    .foregroundColor(Color(.systemGreen))
                            } else {
                                Image(systemName: "xmark.circle.fill")
                                    .imageScale(.large)
                                    .fontWeight(.bold)
                                    .foregroundColor(Color(.systemRed))
                            }
                        }
                    }
                    if !password.isEmpty && !goodPass {
                        Text("Password must contain:")
                            .foregroundColor(Color(.systemRed))
                            .font(.subheadline)
                            .frame(maxWidth: UIScreen.main.bounds.width - 32, alignment: .leading)
                            .padding(.top, -20)
                        Text("At least one uppercase letter")
                            .foregroundColor(Color(.systemRed))
                            .font(.subheadline)
                            .frame(maxWidth: UIScreen.main.bounds.width - 32, alignment: .leading)
                            .padding(.bottom, -20)
                            .padding(.top, -20)
                        Text("At least 8 characters")
                            .foregroundColor(Color(.systemRed))
                            .font(.subheadline)
                            .frame(maxWidth: UIScreen.main.bounds.width - 32, alignment: .leading)
                            .padding(.bottom, -20)
                            .padding(.top, -20)
                        Text("At least one lowercase letter")
                            .foregroundColor(Color(.systemRed))
                            .font(.subheadline)
                            .frame(maxWidth: UIScreen.main.bounds.width - 32, alignment: .leading)
                            .padding(.bottom, -20)
                            .padding(.top, -20)
                        Text("At least one number")
                            .foregroundColor(Color(.systemRed))
                            .font(.subheadline)
                            .frame(maxWidth: UIScreen.main.bounds.width - 32, alignment: .leading)
                            .padding(.bottom, -20)
                            .padding(.top, -20)
                        Text("At least one special character: !@#$%^&*")
                            .foregroundColor(Color(.systemRed))
                            .font(.subheadline)
                            .frame(maxWidth: UIScreen.main.bounds.width - 32, alignment: .leading)
                            .padding(.top, -20)
                        
                    }
                    
                    ZStack(alignment: .trailing) {
                        InputView(text: $confirmPassword,
                                  title: "Confirm Password",
                                  placeholder: "Confirm your password",
                                  isSecureField: true)
                        
                        if !password.isEmpty && !confirmPassword.isEmpty {
                            if password == confirmPassword {
                                Image(systemName: "checkmark.circle.fill")
                                    .imageScale(.large)
                                    .fontWeight(.bold)
                                    .foregroundColor(Color(.systemGreen))
                            } else {
                                Image(systemName: "xmark.circle.fill")
                                    .imageScale(.large)
                                    .fontWeight(.bold)
                                    .foregroundColor(Color(.systemRed))
                            }
                        }
                    }
                    if !password.isEmpty && !confirmPassword.isEmpty && password != confirmPassword {
                        Text("Passwords do not match.")
                            .foregroundColor(Color(.systemRed))
                            .font(.subheadline)
                        // technically not needed because VStack will apply this to other Text elements as well
                            .frame(maxWidth: UIScreen.main.bounds.width - 32, alignment: .leading)
                            .padding(.top, -20)
                    }
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
                
                Button {
                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                    viewModel.loading = true
                    Task {
                        try await viewModel.createUser(withEmail: email,
                                                       password: password,
                                                       fullname: fullname)
                    }
                } label: {
                    HStack {
                        Text("REGISTER")
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
                    HStack(spacing: 3) {
                        Text("Already have an account?")
                        Text("Sign In")
                            .fontWeight(.bold)
                    }
                    .font(.system(size: 14))
                }
                
                Spacer()
            }
            if viewModel.loading {
                LoadingView(text: "Registering...")
            }
        }
    }
}

// form validation extension
extension RegistrationView: AuthenticationFormProtocol {
    
    var formIsValid: Bool {
        return !email.isEmpty
        && validEmail(email)
        && !password.isEmpty
        && validPass(password)
        && confirmPassword == password
        && !fullname.isEmpty
        && viewModel.cloudEnabledStatus
    }
    
    func validPass(_ password: String) -> Bool {
        let passwordRegex  = "^(?=.*[A-Z])(?=.*[!@#$%^&*])(?=.*[0-9])(?=.*[a-z]).{8,}$"
//        ^                         Start anchor
//        (?=.*[A-Z])               Ensure string has one uppercase letter.
//        (?=.*[!@#$%^&*])          Ensure string has one special case letter.
//        (?=.*[0-9])               Ensure string has one digit.
//        (?=.*[a-z])               Ensure string has one lowercase letter.
//        .{8,}                      Ensure string is at least of length 8.
//        $                         End anchor.
        let passwordPredicate = NSPredicate(format: "SELF MATCHES %@", passwordRegex)
        return passwordPredicate.evaluate(with: password)
    }
    
    func validEmail(_ email: String) -> Bool {
        let emailRegex  = "^[A-Z0-9._%+-]+@[A-Z0-9.-]+\\.[A-Z]{2,64}$"
        let emailPredicate = NSPredicate(format: "SELF MATCHES[c] %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
}

#Preview {
    RegistrationView()
}
