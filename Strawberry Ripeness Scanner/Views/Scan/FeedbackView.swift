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
    @Binding var path: [ScanPath]
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
                    
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Feedback:")
                            .foregroundColor(Color(.darkGray))
                            .fontWeight(.semibold)
                            .font(.footnote)
                        
                        TextField("Type your issue here...", text: $feedback, axis: .vertical)
                            .padding(10)
                            .frame(maxWidth: UIScreen.main.bounds.width - 32)
                            .lineLimit(5...)
                            .font(.system(size: 14))
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.black, lineWidth: 1)
                            )
                    }
                    
                    if viewModel.cloudEnabledStatus == false {
                        Text("Server is currently down for maintenance.")
                            .foregroundColor(Color(.systemRed))
                            .font(.subheadline)
                    }
                    Button {
                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                        fbvm.uploadFeedback(myImage, feedback: feedback, email: vm.currentUser?.email ?? "", userID: vm.currentUser?.id ?? "", completion: {
                            path.removeLast()
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
                print("Navigation Path: \(path)")
                if vm.selectedImage == nil {
                    noImageAlert = true
                }
            }
            .alert("An error occured while loading the image. Please select the image you have feedback on and try again.", isPresented: $noImageAlert) {
                Button("OK", role: .cancel, action: {path.removeLast()})
            }
            if fbvm.loading {
                LoadingView(text: "Submitting feedback...")
            }
        }
    }
}

extension FeedbackView {
    var submitEnabled: Bool {
        return !feedback.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && viewModel.cloudEnabledStatus
    }
}


