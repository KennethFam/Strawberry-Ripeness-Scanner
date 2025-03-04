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
    
    var body: some View {
        if let user = viewModel.currentUser {
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
                        
                        Text("1.0.0")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                }
                
                Section {
                    Button {
                        viewModel.signOut()
                    } label: {
                        HStack {
                            Spacer()
                            SettingsRowView(title: "Sign Out",
                                            tintColor: .red,
                                            textColor: .red)
                            Spacer()
                        }
                    }
                    .onChange(of: vm.syncing) {
                        print(vm.syncing)
                    }
                    .disabled(vm.syncing)
                    .opacity(!vm.syncing ? 1.0 : 0.5)
                    
                }
                
                Section {
                    Button {
                        Task {
                            await viewModel.deleteAccount()
                        }
                    } label: {
                        HStack {
                            Spacer()
                            SettingsRowView(title: "Delete Account",
                                            tintColor: .red,
                                            textColor: .red)
                            Spacer()
                        }
                    }
                    .disabled(vm.syncing)
                    .opacity(!vm.syncing ? 1.0 : 0.5)
                }
                .listSectionSpacing(10)
            }
        }
    }
}

#Preview {
    ProfileView()
        .environmentObject(AuthViewModel())
        .environmentObject(ViewModel())
}
