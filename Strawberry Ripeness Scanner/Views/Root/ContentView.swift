//
//  ContentView.swift
//  Strawberry Ripeness Scanner
//
//  Created by Kenneth Pham on 1/14/25.
//

import SwiftUI

struct ContentView: View {
    @State var selectedTab = 1
    @EnvironmentObject var viewModel: AuthViewModel
    @EnvironmentObject var vm: ViewModel
    
    var body: some View {
        TabView(selection: $selectedTab) {
            Group {
                ScanView()
                    .tabItem {
                        Image(systemName: "plus.circle")
                        Text("Scan")
                    }
                    .tag(1)
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
                
                Group {
                    if viewModel.userSession != nil {
                        ProfileView()
                    } else {
                        LoginView()
                    }
                }
                    .tabItem {
                        Image(systemName: "person.circle")
                        Text("Account")
                    }
                    .tag(2)
                    
            }
            .toolbarBackground(.visible, for: .tabBar)
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(ViewModel())
        .environmentObject(AuthViewModel())
}


