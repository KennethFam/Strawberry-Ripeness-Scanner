//
//  ScanView.swift
//  Strawberry Ripeness Scanner
//
//  Created by Kenneth Pham on 2/24/25.
//

import SwiftUI

struct ScanView: View {
    @EnvironmentObject var vm: ViewModel
    @EnvironmentObject var fbvm: FeedbackViewModel
    @Binding var path: [ScanPath]
    @State private var showDatePicker = false
    @State private var rotation: Double = 0
    @State var showDeleteImageConfirmation = false
    @State var showDeleteAllImagesConfirmation = false
    @State var loadingText = "Loading..."
    @State var startDate = Date()
    @State var endDate = Date()
    @State var presentSideMenu = false
    var body: some View {
        NavigationStack(path: $path) {
            ZStack {
                VStack {
                    //Text("Start Date: \(vm.date), End Date: \(vm.endDate)")
                    HStack {
                        Button {
                            presentSideMenu.toggle()
                        } label: {
                            Image(systemName: "line.3.horizontal")
                                .font(.system(size: 34))
                        }
                        .padding(.leading, 16)
                        .foregroundColor(.black)
                        
                        Text("My Scans")
                            .font(.system(size: 34, weight: .bold))
                            .bold()
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        Spacer()
                        
                        menuEditGroup
                            .disabled(!enableMassEditGroup)
                            .opacity(!enableMassEditGroup ? 1.0 : 0.5)
                            .padding(.trailing, 16)
                    }
                    
                    VStack {
                        HStack {
                            HStack(spacing: 0) {
                                if vm.currentUser != nil {
                                    Text("Cloud Status: ")
                                        .padding(.leading, 16)
                                        .font(.system(size: 14))
                                        .padding(.trailing, 0)
                                    if vm.syncing {
                                        Text("Syncing ")
                                            .font(.system(size: 14))
                                        
                                        ZStack {
                                            Circle()
                                                .stroke(lineWidth: 4)
                                                .opacity(0.3)
                                                .foregroundColor(.gray)
                                            
                                            Circle()
                                                .trim(from: 0, to: 0.25)
                                                .stroke(style: StrokeStyle(lineWidth: 4, lineCap: .round, lineJoin: .round))
                                                .foregroundColor(.black)
                                                .rotationEffect(.degrees(rotation))
                                                .animation(.linear(duration: 1).repeatForever(autoreverses: false), value: rotation)
                                                .onAppear {
                                                    self.rotation = 360
                                                }
                                                .onDisappear {
                                                    self.rotation = 0
                                                }
                                        }
                                        .compositingGroup()
                                        .frame(width: 12)
                                    } else {
                                        Text("Synced")
                                            .font(.system(size: 14))
                                            .foregroundColor(.green)
                                        Image(systemName: "checkmark.icloud")
                                            .foregroundColor(.green)
                                    }
                                }
                                
                            }
                            Spacer()
                        }
                        
                        HStack {
                            
                            Spacer()
                            
                            Menu {
                                Button {
                                    if vm.interval != .allTime {
                                        vm.interval = .allTime
                                        vm.loadImages()
                                    }
                                } label: {
                                    Text("All Time")
                                }
                                
                                Button {
                                    if vm.interval != .today {
                                        vm.interval = .today
                                        vm.loadImages()
                                    }
                                } label: {
                                    Text("Today")
                                }
                                
                                Button {
                                    vm.interval = .custom
                                    vm.date = startDate
                                    vm.endDate = endDate
                                    vm.loadImages()
                                } label: {
                                    Text(getDate(startDate, "MM/dd/yyyy") == getDate(endDate, "MM/dd/yyyy") ? "Custom: \(getDate(startDate, "MM/dd/yyyy"))" : "Custom: \(getDate(startDate, "MM/dd/yyyy")) to \(getDate(endDate, "MM/dd/yyyy"))")
                                }
                            } label: {
                                Text("Generate Report")
                                Image(systemName: "arrow.triangle.2.circlepath")
                                    .padding(.trailing, 16)
                            }
                        }
                        
                        HStack {
                            Spacer()
                            Text("Start")
                                .font(.system(size: 14))
                            Image(systemName: "calendar")
                                .font(.title3)
                                .offset(x: -2)
                                .overlay{
                                    DatePicker("Select Date", selection: $startDate,displayedComponents: [.date])
                                        .blendMode(.destinationOver)
                                    
                                }
                            
                            Text("End")
                                .font(.system(size: 14))
                            Image(systemName: "calendar")
                                .font(.title3)
                                .offset(x: -2)
                                .overlay{
                                    DatePicker("", selection: $endDate, in: startDate..., displayedComponents: [.date])
                                        .blendMode(.destinationOver)
                                    
                                }
                        }
                        .padding(.trailing, 35)
                    }
                    .padding(.top, -25)
                    .padding(.bottom, 10)
                    
                    
                    VStack {
                        if !vm.isEditing {
                            imageScroll
                        }
                        selectedImage
                        HStack {
                            if !vm.isEditing {
                                pickerButtons
                                    .padding(.horizontal)
                            }
                            Spacer()
                            if vm.imageChanged {
                                ButtonLabel(text: "Scan") {
                                    loadingText = "Scanning..."
                                    vm.loading = true
                                    vm.addMyImage(image: vm.image!)
                                }
                                .frame(width: 50, height: 50)
                                .foregroundColor(Color.white)
                                .background(Color.red)
                                .clipShape(Circle())
                            } else if vm.selectedImage != nil {
                                NavigationLink(value: ScanPath.feedback) {
                                    VStack(spacing: 3) {
                                        Text("Have feedback?")
                                        Text("Tap here!")
                                            .fontWeight(.bold)
                                    }
                                    .font(.system(size: 14))
                                }
                            }
                            Spacer()
                            if vm.image != nil {
                                editGroup
                                    .padding(.horizontal)
                            }
                        }
                        .padding(.top, -5)
                        Spacer()
                    }
                    .task {
                        if FileManager().docExist(named: fileName) {
                            vm.loadMyImagesJSONFile()
                        }
                    }
                    .sheet(isPresented: $vm.showPicker) {
                        ImagePicker(sourceType: vm.source == .library ? .photoLibrary : .camera, selectedImage: $vm.image, onImagePicked: { image in // closure function
                            // only executed if user chooses image
                            vm.imageChanged = true
                            vm.isEditing = false
                        })
                    }
                    .alert("Error", isPresented: $vm.showFileAlert, presenting: vm.appError, actions:
                            { cameraError in
                        cameraError.button
                    }, message: { cameraError in
                        Text(cameraError.message)
                    })
                }
                SideMenu(presentSideMenu: $presentSideMenu, content: AnyView(SideMenuView(path: $path, presentSideMenu: $presentSideMenu)))
                if vm.loading {
                    LoadingView(text: loadingText)
                }
            }
            .navigationDestination(for: ScanPath.self) { i in
                switch i {
                case .feedback: FeedbackView(path: $path)
                case .tutorial:
                    TutorialView()
                case .ripenessGuide:
                    RipenessGuideView()
                case .support:
                    ContactView(path: $path)
                }
            }
        }
    }
}


