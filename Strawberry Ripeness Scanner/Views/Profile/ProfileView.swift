//
//  ProfileView.swift
//  Strawberry Ripeness Scanner
//
//  Created by Kenneth Pham on 2/25/25.
//

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var viewModel: AuthViewModel
    @EnvironmentObject var vm: ViewModel
    @State var loadingText = "Syncing Photos..."
    @State var syncLoading = false
    @State var logOut = false
    @State var deleteAcc = false
    @State var showSignOutConfirmation = false
    @State var showDeleteAccountConfirmation = false
    
    var body: some View {
        if let user = viewModel.currentUser {
            ZStack {
                List {
                    Section {
                        HStack {
                            Text(user.initials)
                                .font(.title)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .frame(width: 72, height: 72)
                                .background(Color(.systemGray3))
                                .clipShape(Circle())
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(user.fullname)
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                    .padding(.top, 4)
                                
                                Text(user.email)
                                    .font(.footnote)
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                    
                    Section("General") {
                        HStack {
                            SettingsRowView(imageName: "gear",
                                            title: "Version",
                                            tintColor: Color(.systemGray))
                            
                            Spacer()
                            
                            Text(AppData.version)
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                    }
                    
                    Section {
                        Button {
                            showSignOutConfirmation = true
                        } label: {
                            HStack {
                                Spacer()
                                SettingsRowView(title: "Sign Out",
                                                tintColor: .red,
                                                textColor: .red)
                                Spacer()
                            }
                        }
                        .confirmationDialog("Are you sure you want to sign out?", isPresented: $showSignOutConfirmation, titleVisibility: .visible) {
                            Button("Sign Out", role: .destructive) {
                                loadingText = "Signing out..."
                                if !vm.syncing {
                                    viewModel.signOut()
                                } else {
                                    syncLoading = true
                                    logOut = true
                                }
                            }
                        }
                        .alert("An error occured while signing out. Please try again.", isPresented: $viewModel.signOutError) {
                            Button("OK", role: .cancel, action: {
                                print("Sign out error acknowledged.")
                            })
                        }
                        
                    }
                    
                    Section {
                        Button {
                            showDeleteAccountConfirmation = true
                        } label: {
                            HStack {
                                Spacer()
                                SettingsRowView(title: "Delete Account",
                                                tintColor: .red,
                                                textColor: .red)
                                Spacer()
                            }
                        }
                        .confirmationDialog("Are you sure you want to delete your account?", isPresented: $showDeleteAccountConfirmation, titleVisibility: .visible) {
                            Button("Delete Account", role: .destructive) {
                                loadingText = "Deleting Account..."
                                if !vm.syncing {
                                    Task {
                                        await viewModel.deleteAccount()
                                    }
                                } else {
                                    syncLoading = true
                                    deleteAcc = true
                                }
                            }
                        }
                        .alert("An error occured while deleting your account. You will be signed out now. Please log in and try again.", isPresented: $viewModel.deleteAccError) {
                            Button("OK", role: .cancel, action: {
                                if !vm.syncing {
                                    viewModel.signOut()
                                } else {
                                    syncLoading = true
                                    logOut = true
                                }
                            })
                        }
                    }
                    .listSectionSpacing(10)
                }
                
                if viewModel.loading || syncLoading {
                    LoadingView(text: loadingText)
                }
            }
            .onChange(of: vm.syncing) {
                print(vm.syncing)
                if !vm.syncing {
                    if syncLoading { syncLoading = false }
                    if logOut {
                        print("\nSigning out right now!\n")
                        viewModel.signOut()
                        logOut = false
                    } else if deleteAcc {
                        Task {
                            defer {deleteAcc = false}
                            await viewModel.deleteAccount()
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    ProfileView()
        .environmentObject(AuthViewModel())
        .environmentObject(ViewModel())
}
