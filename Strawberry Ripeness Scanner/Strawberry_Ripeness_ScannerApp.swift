//
//  Strawberry_Ripeness_ScannerApp.swift
//  Strawberry Ripeness Scanner
//
//  Created by Kenneth Pham on 1/14/25.
//

import SwiftUI
import FirebaseCore

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure()
    return true
  }
}

@main
struct Strawberry_Ripeness_ScannerApp: App {
    // register app delegate for Firebase setup
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    // StateObject is the same as State but for objects
    // creates instance of view model
    @StateObject var vm = ViewModel()
    @StateObject var viewModel = AuthViewModel()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(vm)
                // by making it an environment object, we won't need to redeclare it on every view to for login/registration functions
                .environmentObject(viewModel)
                .onAppear {
                    UserDefaults.standard.setValue(false, forKey: "_UIConstraintBasedLayoutLogUnsatisfiable")
                }
        }
    }
}
