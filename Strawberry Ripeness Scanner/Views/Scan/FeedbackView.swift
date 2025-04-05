//
//  FeedbackView.swift
//  Strawberry Ripeness Scanner
//
//  Created by Kenneth Pham on 3/27/25.
//

import SwiftUI
import UIKit

struct FeedbackView: View {
    @EnvironmentObject var vm: ViewModel
    @EnvironmentObject var fbvm: FeedbackViewModel
    @EnvironmentObject var viewModel: AuthViewModel
    @State var noImageAlert = false
    @State var feedback = ""
    
    var body: some View {
        ZStack {
            VStack {
                HStack {
                    Text("Feedback")
                        .font(.system(size: 34, weight: .bold))
                        .bold()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.leading, 16)
                }
                if let myImage = vm.selectedImage {
                    ZoomableScrollView {
                        Image(uiImage: myImage.image)
                            .resizable()
                            .scaledToFit()
                            .frame(minWidth: 0, maxWidth: .infinity)
                    }
                    TextField("Enter your feedback here...", text: $feedback, axis: .vertical)
                        .textFieldStyle(.roundedBorder)
                        .padding(.horizontal)
                    if viewModel.cloudEnabledStatus == false {
                        Text("Server is currently down for maintenance.")
                            .foregroundColor(Color(.systemRed))
                            .font(.subheadline)
                    }
                    Button {
                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                        fbvm.uploadFeedback(myImage, feedback: feedback, email: vm.currentUser?.email ?? "", userID: vm.currentUser?.id ?? "", completion: {
                            fbvm.path.removeLast()
                            fbvm.loading = false
                        })
                    } label: {
                        HStack {
                            Text("SUBMIT")
                        }
                        .font(.headline)
                        .padding()
                        .frame(height: 40)
                        .background(Color.blue)
                        .foregroundColor(Color(.white))
                        .cornerRadius(15)
                    }
                    .disabled(!submitEnabled)
                    .opacity(submitEnabled ? 1.0 : 0.5)
                }
                Spacer()
            }
            .onTapGesture {
                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
            }
            .onAppear {
                print("Navigation Path: \(fbvm.path)")
                if vm.selectedImage == nil {
                    noImageAlert = true
                }
            }
            .alert("An error occured while loading the image. Please select the image you have feedback on and try again.", isPresented: $noImageAlert) {
                Button("OK", role: .cancel, action: {fbvm.path.removeLast()})
            }
            if fbvm.loading {
                LoadingView(text:"Submitting feedback...")
            }
        }
    }
}

extension FeedbackView {
    var submitEnabled: Bool {
        return !feedback.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && viewModel.cloudEnabledStatus
    }
}

#Preview {
    FeedbackView()
        .environmentObject(ViewModel())
        .environmentObject(FeedbackViewModel())
        .environmentObject(AuthViewModel())
}
