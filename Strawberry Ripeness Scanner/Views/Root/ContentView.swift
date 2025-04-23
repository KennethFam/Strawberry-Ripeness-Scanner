//
//  ContentView.swift
//  Strawberry Ripeness Scanner
//
//  Created by Kenneth Pham on 1/14/25.
//

import SwiftUI

struct ContentView: View {
    @State var selectedTab = 1
    @EnvironmentObject var nm: NetworkMonitor
    @EnvironmentObject var viewModel: AuthViewModel
    @EnvironmentObject var vm: ViewModel
    @Binding var path: [ScanPath]
    
    var body: some View {
        TabView(selection: $selectedTab) {
            Group {
                ScanView(path: $path)
                    .tabItem {
                        Image(systemName: "plus.circle")
                        Text("Scan")
                    }
                    .tag(1)
                
                Group {
                    if nm.connected == false {
                        Text("No internet connection. Please check your network and try again")
                            .font(.system(size: 14))
                            .foregroundColor(.red)
                            
                    }
                    else {
                        if viewModel.currentUser != nil {
                            ProfileView()
                        } else {
                            LoginView()
                        }
                    }
                }
                    .tabItem {
                        Image(systemName: "person.circle")
                        Text("Account")
                    }
                    .tag(2)
                    
            }
            .toolbarBackground(.visible, for: .tabBar)
            // check change of id b/c User type is not equatable
            .onChange(of: viewModel.currentUser) {
                if let authUser = viewModel.currentUser {
                    if let vmUser = vm.currentUser {
                        if (authUser != vmUser) {
                            vm.setUser(authUser)
                            print("vm user changed or new image paths were added!\n")
                        }
                    } else {
                        vm.setUser(authUser)
                        print("vm user signed in!\n")
                    }
                } else {
                    vm.setUser(nil)
                    print("vm user signed out!\n")
                }
            }
            .onChange(of: vm.syncing) {
                viewModel.syncing = vm.syncing
            }
        }
    }
}



